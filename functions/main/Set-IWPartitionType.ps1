function Set-IWPartitionType {
    param(
        #Input Object should be parsed from Get-IWDevice
        [Parameter(ValueFromPipeline)]
        $InputObject = (Get-PSFConfigValue ImageWriterEngine.Session.DeviceInputObject)
    )

    begin {
    }

    process {
        try {
            Clear-Disk -RemoveData -Confirm:$true -InputObject $InputObject -RemoveOEM -ErrorAction Stop
            Write-PSFMessage -Level Host -Message ("Device {0} with serialnumber {1} cleaned." -f $InputObject.FriendlyName, $InputObject.SerialNumber)
        }
        catch {
            throw "Failure while cleaning the disk."
        }
        
        if ($InputObject.PartitionStyle -ne "GPT") {
            try {
                Set-Disk -PartitionStyle GPT -InputObject $InputObject -ErrorAction Stop
                Write-PSFMessage -Level Host -Message ("Device {0} is now GPT" -f $InputObject.FriendlyName)
            }
            catch {
                throw "Failure while setting the Device to GPT."
            }
        }
    }

    end { }
}