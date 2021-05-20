function Set-IWPartitionType {
    param(
        #Input Object should be parsed from Get-IWDevice
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    begin {
    }

    process {
        try {
            Clear-Disk -RemoveData -Confirm:$false -InputObject $InputObject -RemoveOEM -ErrorAction Stop
            # Add log "Device {0} with serialnumber {1} cleaned."
        } catch {
            throw "Failure while cleaning the disk."
        }
        
        if ($InputObject.PartitionStyle -ne "GPT") {
            try {
                Set-Disk -PartitionStyle GPT -InputObject $InputObject -ErrorAction Stop
                # Add log "Device {0} is now GPT"
            } catch {
                throw "Failure while setting the Device to GPT."
            }
        }
    }

    end { }
}