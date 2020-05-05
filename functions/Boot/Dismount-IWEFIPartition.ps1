function Dismount-IWEFIPartition {

    param (
        [Parameter()]
        [char]
        $DriveLetter
    )
    
    begin { }

    process {
        try {
            Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
            Remove-PartitionAccessPath -DiskNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).Disknumber -PartitionNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).EFIPartitionNumber -AccessPath (Get-PSFConfigValue ImageWriterEngine.Session.MountPath)
        }
        catch {
            $dismount = ("mountvol.exe {0} /D" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))
            Invoke-Expression -Command $dismount | Out-Null
        }
    }
    end { }
}