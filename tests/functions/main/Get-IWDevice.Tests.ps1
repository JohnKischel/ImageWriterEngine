Describe "Get-IWDevice" {
    Context "Gets a device by its driveletter." {
        $result = Get-IWDevice -DriveLetter $env:HOMEDRIVE.Replace(":","")

        It "Should return a DiskNumber."{
            $result.Number | Should BeOfType [System.UInt32]
        }

        It "Should have partitionstyle GPT."{
            $result.PartitionStyle | Should Be "GPT"
        }
    }

    Context "Gets a device by its disknumber." {
        $result = Get-IWDevice -DiskNumber 0

        It "Should return a DiskNumber."{
            $result.Number | Should BeOfType [System.UInt32]
        }

        It "Should have partitionstyle GPT."{
            $result.PartitionStyle | Should Be "GPT"
        }
    }

    Context "Should return all available devices" {
        $result = Get-IWDevice -ListAll

        It "returns data"{
            $result | Should Not Be [nullable]
        }
    }
}