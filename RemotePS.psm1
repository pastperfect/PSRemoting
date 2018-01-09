function Get-PsExec {
    <#
    .SYNOPSIS
    Downloads the PsExec excutable from the internet
    
    .DESCRIPTION
    Downloads the PsExec excutable from the internet to a specified location. It can also add this download location to the PATH variable.
    
    .PARAMETER URL
    URL for the PSEXEC executable, default URL is https://live.sysinternals.com/psexec.exe

    .PARAMETER DownloadFolder
    Location to download the PSEXEC executable to, default path is C:\Program Files (x86)\Sysinternals\

    .PARAMETER AddToPath
    Add the download folder to the PATH variable
        
    .EXAMPLE
    Get-PsExec
    Downloads the PsExec executable from the default URL to the default location

    .EXAMPLE
    Get-PsExec -URL http://www.downloadsite.com/psexec.exe -DownloadFolder "C:\Temp\IT Tools"
    Downloads the PsExec execuable from the specified site to the "C:\Temp\IT Tools" folder

    .EXAMPLE
    Get-PsExec -AddToPath
    Downloads the PsExec executable and adds the download folder location to the PATH variable
    
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$false,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [string]$URL = "https://live.sysinternals.com/psexec.exe",

        [parameter(Position=1,
        Mandatory=$false,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [string]$DownloadFolder = "C:\Program Files (x86)\Sysinternals\",

        [parameter(Position=2,
        Mandatory=$false,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [switch]$AddToPath

    )

    begin {
        if (!(Test-Path $DownloadFolder)) {
            $Root_Path = Split-Path -Path $DownloadFolder
            $Folder_Name = Split-Path -Path $DownloadFolder -Leaf
            Write-Verbose "Creating download folder"    
            New-Item -Path $Root_Path -Name $Folder_Name -ItemType Directory | Out-Null
            
            if (!(Test-Path $DownloadFolder)) {
                throw "Unable to access download folder"
            }
        }

        $Exe_Name = Split-Path $URL -Leaf

        if ($DownloadFolder -notmatch '.+?\\$') {
            $DownloadFolder = $DownloadFolder+"\"
        }

        $Output = $DownloadFolder+$Exe_Name
        Write-Verbose "Output path : $Output" 
    }
    process {
        Write-Verbose "Starting Download"
        Invoke-WebRequest -Uri $url -OutFile $output
    }
    end {
        if ($AddToPath.IsPresent) {
            Write-Verbose "Adding download folder to the PATH variable"
            $Current_Path = (Get-ItemProperty -Path 'Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
            
            $New_Path = $Current_Path+";"+$DownloadFolder
            
            Set-ItemProperty -Path 'Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $New_Path

            Write-Warning "Please restart PowerShell for the change to PATH variable to take effect"
        }
    }
}

function Test-RemotePS {
    <#
    .SYNOPSIS
    Tests if PSRemoting is enabled and working on a remote machine
    
    .DESCRIPTION
    Tests if PSRemoting is enabled and working on a remote machine.
    
    .PARAMETER Computer
    Name of remote computer

    .PARAMETER Silent
    Returns output as True or False
        
    .EXAMPLE
    Test-RemotePS -Computer PC01
    Tests if PSRemoting is enabled on PC01 and returns a message to the console

    .EXAMPLE
    Test-RemotePS -Computer PC01 -Silent
    Tests if PSRemoting is enabled on PC01 and returns output as either True or False
    
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [string]$Computer,

        [parameter(Position=1,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [switch]$Silent
    )

    begin {
        if (!(Test-Connection $Computer -Count 2 -Quiet)) {
            throw "Machine may be offline"                        
        }
    }
    process {
        $Result = [bool](Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue)
    }
    end {
        if ($silent.IsPresent) {
            $Result
        } else {
            if ($Result -eq $true) {
                Write-Host "PSRemoting is enabled" -ForegroundColor Green
            } else {
                Write-Host "PSRemoting is not enabled or is broken" -ForegroundColor Gray
            }
        }
    }
}

function Enable-RemotePS {
    <#
    .SYNOPSIS
    Enables PSremoting on a remote machine
    
    .DESCRIPTION
    Enables PSRemoting on a remote machine by using PSEXEC to initiate the Enable-PSRemoting command on the remote machine.
    
    .PARAMETER Computer
    Name of remote computer
    
    .PARAMETER SpecifyPSEXEC
    This parameter is needed if you havent specified the PSEXEC file in your PATH variable
    
    .PARAMETER ExeLocation
    Location of the PSEXEC Executable
    
    .EXAMPLE
    Enable-RemotePS -Computer PC01
    Enables PSRemoting on PC01 using the PSEXEC exe found in your PATH variable

    .EXAMPLE
    Enable-RemotePS -Computer PC01 -SpecifyPSExec -ExeLocation C:\TMP\PsExec.exe
    Enables PSRemoting on PC01 using the PsExec.exe program found in C:\TMP\
    
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [parameter(Position=0,
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ParameterSetName='PSEXEC')]
        [string]$Computer,

        [parameter(Position=1,ParameterSetName='PSEXEC')]
        [switch]$SpecifyPSEXEC,

        [parameter(Position=2,Mandatory=$true,ParameterSetName='PSEXEC')]
        [String]$ExeLocation        
        
    )

    begin {
        if ($SpecifyPSEXEC.IsPresent) {            
            if (!(Test-Path $ExeLocation)) {                
                Write-Error "PSEXEC file not found"
                return
            } else {
                $PSEXEC = $ExeLocation
                Write-Verbose "PSEXEC.EXE location set to: $PSEXEC" 
            }
        } else {
            $PSEXEC = (Get-Command PSEXEC.exe).source
            Write-Verbose "PSEXEC.EXE location set to: $PSEXEC" 
        }
    }
    process {
        if (Test-Connection $Computer -Count 2 -Quiet) {
            Write-Verbose "Running Enable-PSRemoting"
            & $PSEXEC \\$computer -nobanner -h -d powershell.exe "Enable-PSRemoting -Force" >$null 2>$null    
        } else {            
            Write-Error "Unable to connect to remote machine"
        }
    }
}

function Connect-RemotePS {
    <#
    .SYNOPSIS
    Enter a powershell session on a remote machine
    
    .DESCRIPTION
    Enter a powershell session on a remote machine
    
    .PARAMETER Computer
    Name of remote computer

    .PARAMETER NewWindow
    Opens the remote powershell session in a new window
        
    .EXAMPLE
    Connect-RemotePS -Computer PC01
    Opens a powershell session to PC01 in the current console window

    .EXAMPLE
    Connect-RemotePS -Computer PC01 -NewWindow
    Opens a powershell session to PC01 in a new console window

    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [string]$Computer,

        [parameter(Position=1,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [switch]$NewWindow
    )

    begin {
        if (!(Test-Connection $Computer -Count 2 -Quiet)) {
            throw "Machine may be offline"                        
        }
        if (!([bool](Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue))) {
            throw "PowerShell remoting is not enabled on the Remote Machine"                       
        }

    }
    process {
        if ($NewWindow.IsPresent) {
            Start-Process powershell.exe -ArgumentList "-noexit &Enter-Pssession -computer $Computer"           
        } else {
            enter-pssession -computer $Computer
        }
    }
}

function Disable-RemotePS {
    <#
    .SYNOPSIS
    Disables PSremoting on a remote machine
    
    .DESCRIPTION
    Disabless PSRemoting on a remote machine by using PSEXEC to initiate the Disable-PSRemoting command on the remote machine.
    
    .PARAMETER Computer
    Name of remote computer
    
    .PARAMETER SpecifyPSEXEC
    This parameter is needed if you havent specified the PSEXEC file in your PATH variable
    
    .PARAMETER ExeLocation
    Location of the PSEXEC Executable
    
    .EXAMPLE
    Disable-RemotePS -Computer PC01
    Disables PSRemoting on PC01 using the PSEXEC exe found in your PATH variable

    .EXAMPLE
    Disable-RemotePS -Computer PC01 -SpecifyPSExec -ExeLocation C:\TMP\PsExec.exe
    Disables PSRemoting on PC01 using the PsExec.exe program found in C:\TMP\
    
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [parameter(Position=0,
        Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Default')]
        [parameter(Position=0,
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ParameterSetName='PSEXEC')]
        [string]$Computer,

        [parameter(Position=1,ParameterSetName='PSEXEC')]
        [switch]$SpecifyPSEXEC,

        [parameter(Position=2,Mandatory=$true,ParameterSetName='PSEXEC')]
        [String]$ExeLocation        
        
    )

    begin {
        if ($SpecifyPSEXEC.IsPresent) {            
            if (!(Test-Path $ExeLocation)) {                
                Write-Error "PSEXEC file not found"
                return
            } else {
                $PSEXEC = $ExeLocation
                Write-Verbose "PSEXEC.EXE location set to: $PSEXEC" 
            }
        } else {
            $PSEXEC = (Get-Command PSEXEC.exe).source
            Write-Verbose "PSEXEC.EXE location set to: $PSEXEC" 
        }
    }
    process {
        if (Test-Connection $Computer -Count 2 -Quiet) {
            Write-Verbose "Running Disable-PSRemoting"
            & $PSEXEC \\$computer -nobanner -h -d powershell.exe "Disable-PSRemoting -Force" >$null 2>$null
            Write-Verbose "Removing WIMRM listener" 
            & $PSEXEC \\$computer -nobanner -h -d powershell.exe "winrm delete winrm/config/listener?address=*+transport=HTTP" >$null 2>$null
            Write-Verbose "Stopping WINRM service" 
            & $PSEXEC \\$computer -nobanner -h -d powershell.exe "Stop-Service winrm" >$null 2>$null
            Write-Verbose "Setting WINRM startup type to disabled" 
            & $PSEXEC \\$computer -nobanner -h -d powershell.exe "Set-Service -Name winrm -StartupType Disabled" >$null 2>$null
        } else {            
            Write-Error "Unable to connect to remote machine"
        }
    }
}