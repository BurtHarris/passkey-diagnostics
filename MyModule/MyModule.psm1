#Requires -Version 7.0
#Requires -Modules PSFramework
# MyModule.psm1
# Replace this placeholder implementation with your module's functions.
# Add each public function to FunctionsToExport in MyModule.psd1.

# Warn at load time if the module has not been properly initialized from the template.
if ($MyInvocation.MyCommand.ScriptBlock.Module.Guid -eq [guid]'00000000-0000-0000-0000-000000000000') {
    Write-Warning 'MyModule: GUID is still the template placeholder. Run Initialize-Module.ps1 before publishing this module.'
}

# ---------------------------------------------------------------------------
# Module configuration (PSFramework)
# ---------------------------------------------------------------------------
Set-PSFConfig -Module 'MyModule' -Name 'LogLevel' `
    -Value 'Verbose' `
    -Description 'Minimum message level written to the PSFramework log provider.' `
    -Initialize -Validation string

# ---------------------------------------------------------------------------
# Public functions
# ---------------------------------------------------------------------------

# Example function — delete and replace with the real implementation:
function Get-MyModuleInfo {
    <#
    .SYNOPSIS
        Returns basic information about the MyModule module.

    .DESCRIPTION
        Returns the module name and version. Replace this with your own
        implementation after running Initialize-Module.ps1.

    .EXAMPLE
        PS> Get-MyModuleInfo
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-PSFMessage -Level Verbose -Message 'Gathering module information.'

    [PSCustomObject]@{
        Module  = 'MyModule'
        Version = (Get-Module MyModule).Version
    }
}

Export-ModuleMember -Function 'Get-MyModuleInfo'
