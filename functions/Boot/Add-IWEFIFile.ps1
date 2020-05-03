function Add-IWEFIFile {
    [CmdletBinding()]
    param (
        # Location where to look for bootx64.efi
        [char]
        $DriveLetter,

        # Destination of the EFIPartition and Path to place the efifile.
        [string]
        $EFIFilePath = (Get-PSFConfigValue ImageWriterEngine.Session.EFIPath)
    )
    
    begin {
        
    }
    
    process {
        Robocopy.exe ((Get-ChildItem -Path $DriveLetter -Filter 'bootx64.efi' -Recurse).DirectoryName) $EFIFilePath bootx64.efi /S /E /W:1 /R:2
    }
    
    end {
    
    }
}