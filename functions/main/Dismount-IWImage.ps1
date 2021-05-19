function Dismount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImagePath
    )

    begin { 
        if(-not (Test-Path $ImagePath)){
            throw "ImagePath is not valid."
        }
    }

    process {
        do {
            # Cleanup mounted Disks
            $result = Dismount-DiskImage -ImagePath $ImagePath
        }until(!$result)
    }
    end {
        if(!$result){return 0}
    }
}