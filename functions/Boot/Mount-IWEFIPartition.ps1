function Mount-IWEFIPartition {

    param (
        [Parameter()]
        $DriveLetter
    )
    
    begin { 
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }

    process {
        [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.MountPath)) | Out-Null

        try {
            Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
            Add-PartitionAccessPath -DiskNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).Disknumber -PartitionNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).EFIPartitionNumber -AccessPath (Get-PSFConfigValue ImageWriterEngine.Session.MountPath)
        }
        catch {
            $dismount = ("mountvol.exe {0} /D" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))
            Invoke-Expression -Command $dismount | Out-Null
        }
    }

    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}   