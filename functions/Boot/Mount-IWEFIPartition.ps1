function Mount-IWEFIPartition {

    param (
        [Parameter()]
        [string]
        $MountPath,
        [Parameter()]
        [string]
        $DiskNumber,
        [Parameter()]
        [string]
        $PartitionNumber,
        [Parameter()]
        [switch]
        $Unmount
    )
    
    begin {
        $PartitionType = (Get-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber).Type
        if ($PartitionType -ne 'System') {
            throw ("Partition type is {0} bit Type 'System' is expected." -f $PartitionType)
        }

        if (-not (Test-Path $MountPath)) { [System.IO.Directory]::CreateDirectory($MountPath) | Out-Null }
    }

    # The EFI partition of the given device will be mounted.
    process {
        if (-not $Unmount.isPresent) {
            if (-not (Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru -ErrorAction 0)) {
                Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru
                throw "Could not mount efi partition."
            } else {
                # Successfully mounted
                return 0
            }
        } else {
            try{
                Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru | Out-Null
            }catch{
                throw "Could not unmount. Maybe the access path is unmounted?"
            }
        }
    }

    end { }
}   