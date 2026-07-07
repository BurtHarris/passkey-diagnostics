#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..' 'PasskeyDiagnostics' 'PasskeyDiagnostics.psd1'
    Import-Module (Resolve-Path $modulePath) -Force
}

AfterAll {
    Remove-Module PasskeyDiagnostics -ErrorAction SilentlyContinue
}

Describe 'PasskeyDiagnostics module' {
    Context 'Module loading' {
        It 'imports without error' {
            { Import-Module (Resolve-Path (Join-Path $PSScriptRoot '..' 'PasskeyDiagnostics' 'PasskeyDiagnostics.psd1')) -Force } |
                Should -Not -Throw
        }

        It 'exports expected functions' {
            $commands = Get-Command -Module PasskeyDiagnostics
            $commands | Should -Not -BeNullOrEmpty
        }
    }
}
