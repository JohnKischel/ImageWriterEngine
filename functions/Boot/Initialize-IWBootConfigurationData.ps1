function Initialize-IWBootConfigurationData {
    [CmdletBinding()]
    param (
        # Driveletter of the device that should be bootable.
        [Parameter()]
        [char]
        $DriveLetter
    )
    
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }
    
    process {
        Add-IWEFIFile -DriveLetter $DriveLetter
        New-IWBootManager
        Add-IWRamdisk -DriveLetter 'F'
        Add-IWBootLoader | Set-IWBootloader -DriveLetter $DriveLetter
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}