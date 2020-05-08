function Dismount-IWEFIPartition {

    param (
        [Parameter()]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),

        # Path where the EFIpartition should be mounted
        [Parameter()]
        [string]
        $MountPath = (Get-PSFConfigValue ImageWriterEngine.Session.MountPath),

        [Parameter()]
        [string]
        $DiskNumber = (Get-PSFConfigValue ImageWriterEngine.Session.DevicePartition).Disknumber,

        [Parameter()]
        [string]
        $PartitionNumber = (Get-PSFConfigValue ImageWriterEngine.Session.DevicePartition).EFIPartitionNumber
    )
    
    begin { }

    process {
        try {
            Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
            Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath
        }
        catch {
            $dismount = ("mountvol.exe {0} /D" -f $MountPath)
            Invoke-Expression -Command $dismount | Out-Null
        }
    }
    end { }
}