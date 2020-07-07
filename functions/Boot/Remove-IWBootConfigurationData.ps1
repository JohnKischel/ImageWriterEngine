function Remove-IWBootConfigurationData {
    [CmdletBinding()]
    param (
        # Driveletter of the device that should be bootable.
        [Parameter()]
        [char]
        [ValidatePattern('[A-Za-z]')]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),
        # Path to the BootConfigurationData
        [Parameter()]
        [string]
        $StorePath = (Get-PSFConfigValue ImageWriterEngine.Session.StorePath)
    )
    
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }
    
    # Removing the BCD store from the specified device.
    process {
        try {
            Remove-Item -Path $StorePath -Recurse -Force
            Write-PSFMessage -Level Verbose -Message "BootConfigurationData deleted." -Tag Bootloader
        }
        catch {
            throw $_.Exception
        }
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}