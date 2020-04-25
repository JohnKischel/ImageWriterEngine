function Get-IWDevices {
    # TODO: Make a selection enable the user to choose the device.
    try {
        $InputObject = Get-Disk | Where-Object { $_.BusType -eq 'USB' }
        
        switch ($InputObject.Length) {
            0 {
                Write-PSFMessage -Level Host -Message "No usbdevice found."
                throw [System.Exception]::new("Missing usbdevice.")
            }
            1 {
                Write-PSFMessage -Level Host -Message ("USB device with SerialNumber: {0} found." -f $InputObject.SerialNumber)
                return $InputObject
            }
            default {
                Write-PSFMessage -Level Host -Message "More than one usbdevice found."
            }
        }
        
    } catch {
        Write-PSFMessage -Level Host -Message $_.Exception.Message
    }
}