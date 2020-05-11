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
        Get-IWDevices -DriveLetter $DriveLetter | Out-Null
        Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
    }
    
    process {
        Add-IWEFIFile -DriveLetter $DriveLetter

        New-IWBootManager  -DriveLetter $DriveLetter -Force

        Add-IWRamdisk -DriveLetter $DriveLetter
 
        $Identifier = Add-IWBootLoader -DriveLetter $DriveLetter

        Set-IWBootloader -DriveLetter $DriveLetter -Identifier $Identifier
    }
    
    end {
    }
}