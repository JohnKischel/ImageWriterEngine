function Get-IWDevicePartitions {
    param(
        [Parameter()]
        $DriveLetter
    )

    begin {

        if (-not($DriveLetter = Test-DriveLetter -DriveLetter $DriveLetter)) { throw "Could not validate Driveletter $file" }

        $Disknumber = (Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk).Number
        $PartitionList = Get-Partition -DiskNumber $Disknumber
    }

    process {
        
        # Create an new object to store the partitions.
        $DeviceData = New-Object PSCustomObject -Property @{
            Disknumber           = $Disknumber
            EFIPartitionNumber   = ($PartitionList | Where-Object { $_.Type -eq "System" }).PartitionNumber
            BasicPartitionNumber = ($PartitionList | Where-Object { $_.Type -eq "Basic" }).PartitionNumber
        }
        
        # When the partition does not match try to reset / clean the device.
        if (($DeviceData.BasicPartitionNumber).Count -ne 1) {
            Write-Warning -Message "Attention you are forced to delete your device. Please read the following steps carefully. "
            try {
                Reset-IWDevice
            } catch {
                throw "Reset Device failed"
            }
        }

        # Check if all partitions are available.
        if ($DeviceData.Disknumber -and $DeviceData.EFIPartitionNumber -and $DeviceData.BasicPartitionNumber) {
            if ($PartitionList.Type.Contains("Basic") -and $PartitionList.Type.Contains("Reserved") -and $PartitionList.Type.Contains("System")) {
                return $DeviceData
            } else {
                throw 'Missing required partition.'
            }
        }
        return $null
    }

    end { }
}