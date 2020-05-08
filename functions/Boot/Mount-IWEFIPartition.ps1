function Mount-IWEFIPartition {

    param (
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
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
    
    begin {

        $PartitionType = (Get-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber).Type
        if($PartitionType -ne 'System')
        {
            throw ("Partition type is {0} bit Type 'System' is expected." -f $PartitionType)
        }

        Set-PSFConfig ImageWriterEngine.Session.DriveLetter -Value $DriveLetter
        [System.IO.Directory]::CreateDirectory($MountPath) | Out-Null
    }

    process {
        # Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
        if (-not (Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru -ErrorAction 0)) {
            Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru
            if ( -not (Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru -ErrorAction 0)) {
                throw 'Could not mount EFIPartition.'
            }
        }
        Write-PSFMessage -Level Host -Message ("Mounted EFIPartition to {0}" -f $MountPath)
    }

end { }
}   