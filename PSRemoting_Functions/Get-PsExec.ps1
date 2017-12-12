function Get-PsExec {
    <#
    .SYNOPSIS
    Downloads the PsExec excutable from the internet
    
    .DESCRIPTION
    Downloads the PsExec excutable from the internet to a specified location. It can also add this download location to the PATH variable
    
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
            
            Set-ItemProperty -Path 'Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $New_Path

            Write-Warning "Please restart PowerShell for the change to PATH variable to take effect"
        }
    }
}