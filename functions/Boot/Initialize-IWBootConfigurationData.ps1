function Initialize-IWBootConfigurationData {
    [CmdletBinding()]
    param (
        # Driveletter of the device that should be bootable.
        [Parameter()]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.Driveletter)
    )
    
    begin {
        #Mount-IWEFIPartition -DriveLetter $DriveLetter
        Get-IWDevices -DriveLetter $DriveLetter
    }
    
    process {
        Add-IWEFIFile -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        New-IWBootManager  -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        Add-IWRamdisk -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        $Identifier = Add-IWBootLoader -DriveLetter $DriveLetter
        Start-Sleep -Seconds 1
        Set-IWBootloader -DriveLetter $DriveLetter -Identifier $Identifier
        Start-Sleep -Seconds 1
    }
    
    end {
        #Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}