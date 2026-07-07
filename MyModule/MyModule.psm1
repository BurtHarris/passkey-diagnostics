#Requires -Version 7.0
# MyModule.psm1
# Replace this placeholder implementation with your module's functions.
# Add each public function to FunctionsToExport in MyModule.psd1.

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
