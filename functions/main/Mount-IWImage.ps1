function Mount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [AllowNull()]
        [string]
        $ImagePath = (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
    )

    begin {
        if ([String]::IsNullOrEmpty($ImagePath)) {
            Write-PSFMessage -Level Host -Message "Searching for image locally."
            $ImagePath = (Get-ChildItem -Path (Join-PSFPath (Get-PSFConfigValue ImageWriterEngine.Session.Path) -Child "*.iso") -ErrorAction 0).FullName
            if ($ImagePath) {
                Write-PSFMessage -Level Host -Message ("Image: {0} found." -f $ImagePath)
            }
        }

        if (-not ($ImagePath -match ".+\.iso") -or -not (Test-Path -Path $ImagePath)) {
            throw ("Path doesnt match '.+\.iso' or is not available.")
        }

        Dismount-IWImage -ImagePath $ImagePath
    }
    process {
        
        try {
            $InputObject = Get-DiskImage $ImagePath | Mount-DiskImage -PassThru | Get-Volume
        } catch {
            throw "The file or directory is corrupted and unreadable."
        }

        if ($InputObject -and $InputObject.DriveLetter) {
            Write-PSFMessage -Level Host -Message ("Image: [ {0} ] mounted as [ {1}: ] with size [ {2:f2} ]" -f $InputObject.FileSystemLabel , $InputObject.DriveLetter, ($InputObject.Size / 1GB ))       
            Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImage -Value $InputObject -Description "Mounted Image as object."
            Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImagePath -Value $ImagePath -Description "ISO ImagePath"
        } else {
            Dismount-IWImage -ImagePath $ImagePath
            $InputObject = Get-DiskImage $ImagePath | Mount-DiskImage -PassThru | Get-Volume
            Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImage -Value $InputObject -Description "Mounted Image as object."
            Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImagePath -Value $ImagePath -Description "ISO ImagePath"
            if (-not $InputObject -and -not $InputObject.DriveLetter) {
                throw ("Could not mount Image the returning Object was null or no driveletter was assigned to. DriveLetter - {0} -" -f $InputObject.DriveLetter )       

            }
        }
    

        if ([System.IO.File]::Exists(("{0}:\Deploy\Boot\LiteTouchPE_x64.wim" -f $InputObject.DriveLetter))) {
            Write-PSFMessage -Level Host -Message ("WinPE detected.")       
        } else {
            throw 'ISO is not a WINPE.'
        }
    }

    end { 
        return $InputObject
    }
}