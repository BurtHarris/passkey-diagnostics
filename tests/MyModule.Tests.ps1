#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }
#Requires -Modules @{ ModuleName = 'PSFramework'; ModuleVersion = '1.0.0' }

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..' 'MyModule' 'MyModule.psd1'
    Import-Module (Resolve-Path $modulePath) -Force
}

AfterAll {
    Remove-Module MyModule -ErrorAction SilentlyContinue
}

Describe 'MyModule module' {
    Context 'Module loading' {
        It 'imports without error' {
            {
                Import-Module (Resolve-Path (Join-Path $PSScriptRoot '..' 'MyModule' 'MyModule.psd1')) -Force
            } | Should -Not -Throw
        }

        It 'exports expected functions' {
            $commands = Get-Command -Module MyModule
            $commands | Should -Not -BeNullOrEmpty
        }

        It 'PSFramework is available as a dependency' {
            Get-Module PSFramework -ListAvailable | Should -Not -BeNullOrEmpty
        }
    }

    Context 'PSFramework configuration' {
        It 'registers MyModule.LogLevel config entry' {
            $config = Get-PSFConfig -Module MyModule -Name LogLevel
            $config | Should -Not -BeNullOrEmpty
        }

        It 'MyModule.LogLevel defaults to Verbose' {
            $value = Get-PSFConfigValue -FullName 'MyModule.LogLevel'
            $value | Should -Be 'Verbose'
        }
    }
}
