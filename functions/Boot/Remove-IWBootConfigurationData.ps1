function Remove-IWBootConfigurationData {
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
        Remove-Item -Path (Get-PSFConfigValue ImageWriterEngine.Session.StorePath) -Recurse -Force
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}