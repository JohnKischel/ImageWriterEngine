function Initialize-IWBootConfigurationData {
    [CmdletBinding()]
    param (
        # Driveletter of the device that should be bootable.
        [Parameter()]
        [char]
        [ValidatePattern('[A-Za-z]')]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.Driveletter)
    )
    
    begin {
        Get-IWDevice -DriveLetter $DriveLetter | Out-Null
        Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
    }
    
    # Multiple functions from the scripts are executed in the given order to prepare the device wich is specified.
    process {

        # Add log "Invoke Add-IWEFile"
        Add-IWEFIFile -DriveLetter $DriveLetter
        # Add log "Invoke New-IWBootManager"
        New-IWBootManager  -DriveLetter $DriveLetter -Force
        # Add log "Invoke Add-IWRamdisk"
        Add-IWRamdisk -DriveLetter $DriveLetter
        # Add log "Invoke Add-IWBootLoader"
        $Identifier = Add-IWBootLoader -DriveLetter $DriveLetter
        # Add log "Invoke Set-IWBootloader"
        Set-IWBootloader -DriveLetter $DriveLetter -Identifier $Identifier
    }
    
    end {
    }
}