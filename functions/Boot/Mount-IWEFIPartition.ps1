function Mount-IWEFIPartition {

    param (
        [Parameter()]
        [char]
        $DriveLetter
    )
    
    [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.MountPath)) | Out-Null

    try {
        Get-IWDevicePartitions -DriveLetter $DriveLetter
        Add-PartitionAccessPath -DiskNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).Disknumber -PartitionNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).EFIPartitionNumber -AccessPath (Get-PSFConfigValue ImageWriterEngine.Session.MountPath)
    }
    catch {
        $dismount = ("mountvol.exe {0} /D" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))
        Invoke-Expression -Command $dismount
    }
}