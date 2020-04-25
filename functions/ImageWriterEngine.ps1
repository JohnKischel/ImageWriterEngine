function Start-ImageWriterEngine {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [String]
        $ImagePath,

        [Parameter()]
        [Char]
        $DriveLetter
    )
    begin {
        $ErrorActionPreference = "STOP"
    }

    process {
        try {
            $Device, $DriveLetter = Get-IWDevices | Start-IWPrepareDevice -DriveLetter $DriveLetter
            $Image = Mount-IWImage -ImagePath $ImagePath

            Robocopy.exe $("{0}:\" -f $Image.DriveLetter) $("{0}:\" -f $DriveLetter) /S /E /W:1 /R:2
        } catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }
    }

    end {
        # Dismount-DiskImage -InputObject (Get-PSFConfigValue -FullName ImageWriterEngine.Session.DiskImage)
        Remove-Item -Path (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Path) -Child (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Id)) -Force
        $ErrorActionPreference = "Continue"
    }
}

