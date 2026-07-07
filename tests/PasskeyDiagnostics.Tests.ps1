#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }
#Requires -Modules @{ ModuleName = 'PSFramework'; ModuleVersion = '1.0.0' }

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

        It 'PSFramework is available as a dependency' {
            Get-Module PSFramework -ListAvailable | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Get-PasskeyDiagnosticInfo' {
        It 'returns a result object' {
            $result = Get-PasskeyDiagnosticInfo
            $result | Should -Not -BeNullOrEmpty
        }

        It 'result includes ModuleVersion' {
            $result = Get-PasskeyDiagnosticInfo
            $result.ModuleVersion | Should -Not -BeNullOrEmpty
        }

        It 'result includes PSVersion' {
            $result = Get-PasskeyDiagnosticInfo
            $result.PSVersion | Should -Not -BeNullOrEmpty
        }
    }

    Context 'PSFramework configuration' {
        It 'registers PasskeyDiagnostics.LogLevel config entry' {
            $config = Get-PSFConfig -Module PasskeyDiagnostics -Name LogLevel
            $config | Should -Not -BeNullOrEmpty
        }

        It 'PasskeyDiagnostics.LogLevel defaults to Verbose' {
            $value = Get-PSFConfigValue -FullName 'PasskeyDiagnostics.LogLevel'
            $value | Should -Be 'Verbose'
        }
    }
}
