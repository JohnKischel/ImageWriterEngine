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
    
    process {
        try {
            Remove-Item -Path $StorePath -Recurse -Force
            Write-PSFMessage -Level Host -Message "BootConfigurationData deleted."
        }
        catch {
            throw $_.Exception
        }
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}