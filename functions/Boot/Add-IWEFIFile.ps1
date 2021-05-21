function Add-IWEFIFile {
    [CmdletBinding()]
    param (
        # Location where to look for bootx64.efi
        [Parameter(HelpMessage = "Location where to look for bootx64.efi")]
        $Source,

        # Destination of the EFIPartition and Path to place the efifile.
        [string]
        $Destination
    )

    begin {
        $Source = Test-DriveLetter -DriveLetter $Source
        $FullName = ((Get-ChildItem ("{0}:\" -f $Source) -Filter bootx64.efi -Recurse) | Select-Object -First 1).FullName
        $Source = [System.IO.Path]::GetDirectoryName($FullName)
    }
    
    process {
        # Robocopy take care of the image transfer and copies the EFIFile from the iso tho the predefined EFIFilepath.
        Robocopy $Source $Destination bootx64.efi /S /MIR /E /W:1 /R:2 | Out-Null
        # Add log "EFIFile copied to EFI partition."
    }
    
    end {
    }
}