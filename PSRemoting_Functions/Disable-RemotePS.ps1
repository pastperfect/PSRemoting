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