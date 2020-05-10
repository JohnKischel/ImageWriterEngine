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
        Get-IWDevices -DriveLetter $DriveLetter
        Get-IWDevicePartitions -DriveLetter $DriveLetter
    }
    
    process {
        Add-IWEFIFile -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        New-IWBootManager  -DriveLetter $DriveLetter -Force
        Start-Sleep -Seconds 1
        Add-IWRamdisk -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        $Identifier = Add-IWBootLoader -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        Set-IWBootloader -DriveLetter $DriveLetter -Identifier $Identifier
        Start-Sleep -Seconds 1
    }
    
    end {
    }
}