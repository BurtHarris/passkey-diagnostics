#Requires -Version 7.0
# MyModule.psm1
# Replace this placeholder implementation with your module's functions.
# Add each public function to FunctionsToExport in MyModule.psd1.

# Warn at load time if the module has not been properly initialized from the template.
if ($MyInvocation.MyCommand.ScriptBlock.Module.Guid -eq [guid]'00000000-0000-0000-0000-000000000000') {
    Write-Warning 'MyModule: GUID is still the template placeholder. Run Initialize-Module.ps1 before publishing this module.'
}

# Example function — delete and replace with the real implementation:
function Get-MyModuleInfo {
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        Module  = 'MyModule'
        Version = (Get-Module MyModule).Version
    }
}

Export-ModuleMember -Function 'Get-MyModuleInfo'
