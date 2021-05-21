function Mount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [string]
        $ImagePath,

        [switch]
        $ignoreWinPE
    )

    begin {
        if (-not (ValidatePath -Path $ImagePath)) { throw "Could not validate imagepath." }
        Dismount-IWImage -ImagePath $ImagePath | Out-Null
    }

    process {
        
        try {
            $InputObject = Get-DiskImage $ImagePath | Mount-DiskImage -PassThru | Get-Volume
        } catch {
            throw "The file or directory is corrupted and unreadable."
        }

        if (-not($InputObject -and $InputObject.DriveLetter)) {
            Dismount-IWImage -ImagePath $ImagePath
            throw ("Could not mount Image the returning Object was null or no driveletter was assigned to. DriveLetter - {0} -" -f $InputObject.DriveLetter )       
        }
    
        if (-not $ignoreWinPE.isPresent) {
            if ([System.IO.File]::Exists(("{0}:\Deploy\Boot\LiteTouchPE_x64.wim" -f $InputObject.DriveLetter))) {
                # add log
            } else {
                throw 'ISO is not a WINPE.'
            }
        }
    }

    end { 
        return $InputObject.DriveLetter, $InputObject
    }
}