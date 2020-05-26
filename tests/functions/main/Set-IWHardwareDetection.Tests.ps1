Describe "Set-IWHardwareDetection" {
    Context "Deactivate hardware detection." {
        Set-IWHardwareDetection -Stop

        It "Should shutdown the service."{
            (Get-Service -Name "ShellHWDetection").Status | Should Be "Stopped"
        }
    }
    Context "Activate hardware detection." {
        Set-IWHardwareDetection -Start

        It "Should start the service."{
            (Get-Service -Name "ShellHWDetection").Status | Should Be "Running"
        }
    }
}