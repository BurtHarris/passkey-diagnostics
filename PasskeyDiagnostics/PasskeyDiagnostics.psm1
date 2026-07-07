#Requires -Version 7.0
#Requires -Modules PSFramework
# PasskeyDiagnostics.psm1

# ---------------------------------------------------------------------------
# Module configuration (PSFramework)
# ---------------------------------------------------------------------------
Set-PSFConfig -Module 'PasskeyDiagnostics' -Name 'LogLevel' `
    -Value 'Verbose' `
    -Description 'Minimum message level written to the PSFramework log provider.' `
    -Initialize -Validation string

# ---------------------------------------------------------------------------
# Public functions
# ---------------------------------------------------------------------------

function Get-PasskeyDiagnosticInfo {
    <#
    .SYNOPSIS
        Returns diagnostic information about the PasskeyDiagnostics module and
        the current PowerShell environment.

    .DESCRIPTION
        Collects version and platform information useful when troubleshooting
        passkey/WebAuthn issues. All progress messages are routed through
        Write-PSFMessage so they appear in the structured PSFramework log as
        well as the standard Verbose stream.

    .EXAMPLE
        PS> Get-PasskeyDiagnosticInfo

        Returns a PSCustomObject with ModuleVersion, PSVersion, and Platform.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-PSFMessage -Level Verbose -Message 'Gathering passkey diagnostic information.'

    $moduleInfo = Get-Module PasskeyDiagnostics -ErrorAction SilentlyContinue

    if (-not $moduleInfo) {
        Stop-PSFFunction -Message 'PasskeyDiagnostics module is not loaded; cannot retrieve version.' `
            -EnableException $false
        return
    }

    $result = [PSCustomObject]@{
        ModuleVersion = $moduleInfo.Version.ToString()
        PSVersion     = $PSVersionTable.PSVersion.ToString()
        Platform      = $PSVersionTable.Platform
        OS            = $PSVersionTable.OS
    }

    Write-PSFMessage -Level Verbose -Message "Collected diagnostics: PSVersion=$($result.PSVersion), Platform=$($result.Platform)"

    $result
}

Export-ModuleMember -Function 'Get-PasskeyDiagnosticInfo'
