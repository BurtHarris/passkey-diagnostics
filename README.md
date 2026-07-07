# psmodule-template

A GitHub template repository for bootstrapping new PowerShell 7+ modules.
It ships with a module skeleton, Pester 5 tests, GitHub Actions CI, and a
one-shot initialization script that replaces all placeholder names with your
project-specific values.

## Getting started

### 1 — Create a new repository from this template

Click **"Use this template"** on GitHub (or `gh repo create --template BurtHarris/psmodule-template`).

### 2 — Run the initialization script

Clone your new repository, then run:

```powershell
.\Initialize-Module.ps1 -ModuleName 'YourModuleName' -Author 'YourName' `
    -Description 'Short description of what the module does' `
    -Tags 'tag1,tag2'
```

The script will:

- Rename `MyModule/` to `YourModuleName/`
- Rename `MyModule.psd1` / `MyModule.psm1` / `MyModule.Tests.ps1`
- Generate a fresh, unique GUID for the module manifest
- Replace author, description, and GitHub URL placeholders throughout
- Print next steps

Run `Get-Help .\Initialize-Module.ps1 -Full` to see all available parameters.

### 3 — Commit and start building

```powershell
git add -A
git commit -m "feat: initialize YourModuleName module"
git push
```

Then add your functions to `YourModuleName/YourModuleName.psm1`, export them
in the manifest's `FunctionsToExport`, and write tests.

## Development

### Prerequisites

- PowerShell 7+
- [Pester](https://pester.dev) 5.x (`Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser`)

### Running tests

```powershell
Invoke-Pester ./tests
```

### Repository layout

```
psmodule-template/
├── MyModule/
│   ├── MyModule.psd1            # Module manifest (placeholder GUID/names)
│   └── MyModule.psm1            # Module skeleton
├── tests/
│   └── MyModule.Tests.ps1       # Pester test skeleton
├── Initialize-Module.ps1        # One-shot setup script
├── .github/workflows/test.yml   # CI: Pester on windows-latest
└── README.md
```

After running `Initialize-Module.ps1` every `MyModule` occurrence is replaced
with your chosen module name.
