# passkey-diagnostics

PowerShell troubleshooting aides for passkey authentication.

## Module: PasskeyDiagnostics

### Installation

```powershell
# Clone the repo and import directly
Import-Module ./PasskeyDiagnostics/PasskeyDiagnostics.psd1
```

Or once published to the PowerShell Gallery:

```powershell
Install-Module PasskeyDiagnostics
```

### Usage

```powershell
Import-Module PasskeyDiagnostics

# List available commands
Get-Command -Module PasskeyDiagnostics

# Collect passkey diagnostic information
Get-PasskeyDiagnosticInfo

# View structured log messages captured by PSFramework
Get-PSFMessage
```

PSFramework routes all module messages through its structured logging infrastructure. Use `Get-PSFMessage` to inspect the in-memory log and configure logging providers (file, event log, etc.) via `Set-PSFLoggingProvider`.

### Development

#### Prerequisites

- PowerShell 7+
- [Pester](https://pester.dev) 5.x (`Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser`)
- [PSFramework](https://psframework.org) 1.x (`Install-Module PSFramework -MinimumVersion 1.0.0 -Scope CurrentUser`)

#### Running tests

```powershell
Invoke-Pester ./tests
```

#### Repository layout

```
passkey-diagnostics/
├── PasskeyDiagnostics/
│   ├── PasskeyDiagnostics.psd1   # Module manifest
│   └── PasskeyDiagnostics.psm1   # Module implementation
├── tests/
│   └── PasskeyDiagnostics.Tests.ps1
├── .github/workflows/test.yml    # CI (Pester on windows-latest)
└── README.md
```
