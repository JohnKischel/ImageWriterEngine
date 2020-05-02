function Dismount-IWEFIPartition {

    param (
        [Parameter()]
        [char]
        $DriveLetter
    )
    

    try {
        Get-IWDevicePartitions -DriveLetter $DriveLetter
        Remove-PartitionAccessPath -DiskNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).Disknumber -PartitionNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).EFIPartitionNumber -AccessPath (Get-PSFConfigValue ImageWriterEngine.Session.MountPath)
    }
    catch {
        $dismount = ("mountvol.exe {0} /D" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))
        Invoke-Expression -Command $dismount
    }
}