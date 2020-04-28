
function Get-IWDevices {
    
    begin {
        [array]$InputObject = $null
    }
    
    process { 
        
        try {
            foreach ($device in (Get-Disk | Where-Object { $_.BusType -eq 'USB' })) {
                $InputObject += $device; 
            }
            
            switch ($InputObject.Count) {
                0 {
                    Write-PSFMessage -Level Host -Message "No usbdevice found."
                    $errorvar = 1
                }
                1 {
                    Write-PSFMessage -Level Host -Message ("USB device with SerialNumber: {0} found." -f $InputObject.SerialNumber)
                    return $InputObject
                }
                default {
                    Write-PSFMessage -Level Host -Message "Multiple devices found!"
                    $errorvar = 1
                }
            }
            
            if($errorvar -eq 1){exit}
        }
        catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
            exit
        }
    }

    end { }
    
}