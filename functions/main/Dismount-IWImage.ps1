function Dismount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImagePath = (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
    )

    begin {
        if (-not ($ImagePath -match ".+\.iso") -or -not (Test-Path -Path $ImagePath)) {
            throw ("Path doesnt match '.+\.iso' or is not available.")
        }
    }

    process {
        do {
            # Cleanup mounted Disks
            $result = Dismount-DiskImage -ImagePath $ImagePath
        }until(!$result)
    }
    end {
        
    }
}