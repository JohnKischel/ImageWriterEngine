function Add-IWEFIFile {
    [CmdletBinding()]
    param (
        # Location where to look for bootx64.efi
        [char]
        [ValidatePattern('[A-Za-z]')]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),

        # Destination of the EFIPartition and Path to place the efifile.
        [string]
        $EFIFilePath = (Get-PSFConfigValue ImageWriterEngine.Session.EFIPath)
    )
    
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }
    
    process {
        Robocopy ("{0}:\Deploy\Boot\x64\EFI\Boot" -f $DriveLetter) $EFIFilePath bootx64.efi /S /E /W:1 /R:2 | Out-Null
        Write-PSFMessage -Level Host -Message "EFIFile copied to EFI partition."
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}