Describe "Get-IWDevicePartition" {
    Context "Gets all partitions on an device" {
        $result = Get-IWDevicePartitions -DriveLetter $env:HOMEDRIVE.Replace(":","")
        It "Should return an EfiPartitionNumber"{
            $result.EFIPartitionNumber | Should BeOfType [System.UInt32]
        }
        It "Should return a BasicPartitionNumber"{
            $result.EFIPartitionNumber | Should BeOfType [System.UInt32]
        }
        It "Should return a Disknumber"{
            $result.Disknumber | Should BeOfType [System.UInt32]
        }

    }
}