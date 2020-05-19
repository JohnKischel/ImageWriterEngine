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
    
    process {

        Write-PSFMessage -Level Verbose -Message "Invoke Add-IWEFile"
        Add-IWEFIFile -DriveLetter $DriveLetter
        Write-PSFMessage -Level Verbose -Message "Invoke New-IWBootManager"
        New-IWBootManager  -DriveLetter $DriveLetter -Force
        Write-PSFMessage -Level Verbose -Message "Invoke Add-IWRamdisk"
        Add-IWRamdisk -DriveLetter $DriveLetter
        Write-PSFMessage -Level Verbose -Message "Invoke Add-IWBootLoader"
        $Identifier = Add-IWBootLoader -DriveLetter $DriveLetter
        Write-PSFMessage -Level Verbose -Message "Invoke Set-IWBootloader"
        Set-IWBootloader -DriveLetter $DriveLetter -Identifier $Identifier
    }
    
    end {
    }
}