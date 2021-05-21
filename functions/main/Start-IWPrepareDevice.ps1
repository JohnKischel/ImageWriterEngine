function Start-IWPrepareDevice {
    param(
        # This InputObject should be passed from Get-IWDevice
        [Parameter(ValueFromPipeline)]
        $InputObject,

        # This parameter represents the final DriveLetter after installing the Image.
        [Parameter(ValueFromPipeline)]
        $DriveLetter
    )
    
    begin {
        if (-not $Script:IWConfig.loaded) { throw "Script not loaded." }
        $Script:IWConfig.device.newdriveletter = $driveletter = Get-IWDevice -NextDriveLetter
    }

    process {
        # Add log "Started IWPrepareDevice"
        Set-IWPartitionType -InputObject $Script:IWConfig.device.volumeobject
        Set-IWPartition -MSRPartition -InputObject $Script:IWConfig.device.volumeobject
        Set-IWPartition -WindowsPartition `
            -DriveLetter $Script:IWConfig.device.newdriveletter `
            -InputObject $Script:IWConfig.device.volumeobject `
            -LabelName $Script:IWConfig.device.labelname

        Set-IWPartition -EfiPartition -InputObject $Script:IWConfig.device.volumeobject
    }

    end {
        return (Get-IWDevicePartitions -DriveLetter $Script:IWConfig.device.newdriveletter)
    }
}