<#
.SYNOPSIS
    Initializes this repository as a new PowerShell module project.

.DESCRIPTION
    Replaces all placeholder tokens ('MyModule', 'MyAuthor', the zeroed-out GUID,
    and related URLs) with project-specific values, renames files and folders
    accordingly, and optionally removes this script once initialization is complete.

    Run this script exactly once after cloning or generating from the template.

.PARAMETER ModuleName
    Name of the new PowerShell module.  Must start with a letter and contain only
    letters, digits, hyphens, or underscores (e.g. 'AzureHelpers', 'MyTools').

.PARAMETER Author
    Module author name.  Defaults to the value of 'git config user.name'.

.PARAMETER Description
    Short description of the module's purpose.
    Defaults to '<ModuleName> PowerShell module'.

.PARAMETER Tags
    Comma-separated list of PSGallery discovery tags (e.g. 'networking,tools').
    Defaults to an empty array.

.PARAMETER GitHubUser
    GitHub username or organisation that owns the repository.
    Defaults to the owner parsed from the 'origin' remote URL.

.PARAMETER RepoName
    GitHub repository name.  Defaults to <ModuleName> (lower-cased).

.PARAMETER RemoveAfterInit
    When specified, deletes this script from the repository after a successful run.

.EXAMPLE
    .\Initialize-Module.ps1 -ModuleName 'AzureHelpers' -Author 'JaneDoe' `
        -Description 'Helpers for Azure automation' -Tags 'azure,automation'

.EXAMPLE
    .\Initialize-Module.ps1 -ModuleName 'MyTools' -RemoveAfterInit
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_-]*$')]
    [string] $ModuleName,

    [string] $Author,

    [string] $Description,

    [string] $Tags = '',

    [string] $GitHubUser,

    [string] $RepoName,

    [switch] $RemoveAfterInit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helper: replace text in a file (UTF-8, preserving line endings)
# ---------------------------------------------------------------------------
function Update-FileContent {
    param(
        [string] $Path,
        [System.Collections.IDictionary] $Replacements
    )

    $content = Get-Content -LiteralPath $Path -Raw -Encoding utf8
    foreach ($key in $Replacements.Keys) {
        $content = $content.Replace($key, $Replacements[$key])
    }
    Set-Content -LiteralPath $Path -Value $content -Encoding utf8 -NoNewline
}

# ---------------------------------------------------------------------------
# Resolve defaults
# ---------------------------------------------------------------------------
if (-not $Author) {
    $Author = git config user.name 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $Author) {
        Write-Verbose "git config user.name not set; defaulting Author to `$env:USERNAME ('$($env:USERNAME)')"
        $Author = $env:USERNAME
    }
}

if (-not $Description) {
    $Description = "$ModuleName PowerShell module"
}

if (-not $GitHubUser) {
    # Try to extract from the origin remote URL (https or ssh)
    $remoteUrl = git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $remoteUrl) {
        Write-Verbose "No 'origin' remote found; defaulting GitHubUser to Author ('$Author')"
        $GitHubUser = $Author
    } elseif ($remoteUrl -match 'github\.com[:/]([^/]+)/') {
        $GitHubUser = $Matches[1]
    } else {
        Write-Verbose "origin remote '$remoteUrl' is not a GitHub URL; defaulting GitHubUser to Author ('$Author')"
        $GitHubUser = $Author
    }
}

if (-not $RepoName) {
    $RepoName = $ModuleName.ToLowerInvariant()
}

# Build the tags array string for the manifest
$tagsArray = if ($Tags) {
    $tagList = $Tags -split '\s*,\s*' | Where-Object { $_ } | ForEach-Object {
        if ($_ -match "['\`"]") {
            throw "Tag '$_' contains a quote character, which is not valid in a PSGallery tag."
        }
        "'$_'"
    }
    $tagList -join ', '
} else {
    ''
}
$tagsValue = if ($tagsArray) { $tagsArray } else { '' }


# Generate a fresh GUID
$newGuid = [guid]::NewGuid().ToString()

Write-Host "Initializing module '$ModuleName'..."
Write-Host "  Author      : $Author"
Write-Host "  Description : $Description"
Write-Host "  GUID        : $newGuid"
Write-Host "  GitHub      : $GitHubUser/$RepoName"

# ---------------------------------------------------------------------------
# Locate the repository root (script lives at repo root)
# ---------------------------------------------------------------------------
$repoRoot = $PSScriptRoot

# ---------------------------------------------------------------------------
# Replacements map (order matters — longer/more-specific patterns first)
# ---------------------------------------------------------------------------
$replacements = [ordered]@{
    'MyAuthor/MyModule'                    = "$GitHubUser/$RepoName"
    '00000000-0000-0000-0000-000000000000' = $newGuid
    'MyModule PowerShell module'           = $Description
    "(c) MyAuthor. All rights reserved."   = "(c) $Author. All rights reserved."
    "Author = 'MyAuthor'"                  = "Author = '$Author'"
    'MyModule'                             = $ModuleName
    'MyAuthor'                             = $Author
}
if ($tagsValue) {
    $replacements['Tags = @()'] = "Tags = @($tagsValue)"
}

# ---------------------------------------------------------------------------
# Rename module folder: MyModule/ -> <ModuleName>/
# ---------------------------------------------------------------------------
$srcFolder  = Join-Path $repoRoot 'MyModule'
$destFolder = Join-Path $repoRoot $ModuleName

if (Test-Path $srcFolder) {
    if ($PSCmdlet.ShouldProcess($srcFolder, "Rename folder to '$destFolder'")) {
        Rename-Item -LiteralPath $srcFolder -NewName $ModuleName
        Write-Host "Renamed folder: MyModule -> $ModuleName"
    }
} elseif (-not (Test-Path $destFolder)) {
    Write-Warning "Module folder '$srcFolder' not found and '$destFolder' does not exist."
}

# ---------------------------------------------------------------------------
# Rename module files inside the (now-renamed) folder
# ---------------------------------------------------------------------------
$moduleFolder = Join-Path $repoRoot $ModuleName
foreach ($ext in @('psd1', 'psm1')) {
    $srcFile  = Join-Path $moduleFolder "MyModule.$ext"
    $destFile = Join-Path $moduleFolder "$ModuleName.$ext"
    if (Test-Path $srcFile) {
        if ($PSCmdlet.ShouldProcess($srcFile, "Rename to '$destFile'")) {
            Rename-Item -LiteralPath $srcFile -NewName "$ModuleName.$ext"
            Write-Host "Renamed: MyModule.$ext -> $ModuleName.$ext"
        }
    }
}

# ---------------------------------------------------------------------------
# Rename the tests file: tests/MyModule.Tests.ps1 -> tests/<ModuleName>.Tests.ps1
# ---------------------------------------------------------------------------
$srcTest  = Join-Path $repoRoot 'tests' 'MyModule.Tests.ps1'
$destTest = Join-Path $repoRoot 'tests' "$ModuleName.Tests.ps1"
if (Test-Path $srcTest) {
    if ($PSCmdlet.ShouldProcess($srcTest, "Rename to '$destTest'")) {
        Rename-Item -LiteralPath $srcTest -NewName "$ModuleName.Tests.ps1"
        Write-Host "Renamed: MyModule.Tests.ps1 -> $ModuleName.Tests.ps1"
    }
}

# ---------------------------------------------------------------------------
# Update content of all relevant files
# ---------------------------------------------------------------------------
$filesToUpdate = @(
    Join-Path $moduleFolder "$ModuleName.psd1"
    Join-Path $moduleFolder "$ModuleName.psm1"
    Join-Path $repoRoot 'tests' "$ModuleName.Tests.ps1"
    Join-Path $repoRoot 'README.md'
)

foreach ($file in $filesToUpdate) {
    if (Test-Path $file) {
        if ($PSCmdlet.ShouldProcess($file, 'Update placeholder content')) {
            Update-FileContent -Path $file -Replacements $replacements
            Write-Host "Updated: $file"
        }
    }
}

# ---------------------------------------------------------------------------
# Optionally remove this script
# ---------------------------------------------------------------------------
if ($RemoveAfterInit) {
    $selfPath = $PSCommandPath
    if ($PSCmdlet.ShouldProcess($selfPath, 'Remove initialization script')) {
        Remove-Item -LiteralPath $selfPath -Force
        Write-Host "Removed: Initialize-Module.ps1"
    }
}

Write-Host ''
Write-Host "Done.  Module '$ModuleName' is ready."
Write-Host "Next steps:"
Write-Host "  1. Review and commit the changes (git add -A && git commit)"
Write-Host "  2. Add your functions to $ModuleName/$ModuleName.psm1"
Write-Host "  3. Export them in $ModuleName/$ModuleName.psd1 (FunctionsToExport)"
Write-Host "  4. Add tests in tests/$ModuleName.Tests.ps1"
Write-Host "  5. Push and enable CI via .github/workflows/test.yml"
