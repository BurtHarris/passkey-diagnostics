#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }

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
    }
}
