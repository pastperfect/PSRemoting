#
# Module manifest for module 'RemotePS'
#
# Generated by: Ricky Burgess
#
# Generated on: 07/12/2017
#

@{

# Script module or binary module file associated with this manifest.
RootModule = '.\RemotePS.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '844fd2c5-6210-4243-a2cd-21c378eba94d'

# Author of this module
Author = 'Ricky Burgess'

# Company or vendor of this module
CompanyName = 'Sword IT Solutions'

# Copyright statement for this module
Copyright = '(c) 2017 Ricky Burgess. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This module provides functions to assist with managing PSRemoting on remote machines.'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Get-PsExec','Test-RemotePS','Enable-RemotePS','Connect-RemotePS','Disable-RemotePS'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

