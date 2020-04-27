function Start-ImageWriterEngine {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage="Path of the isofile.")]
        [ValidateNotNullorEmpty()]
        [String]
        $ImagePath,

        [Parameter(HelpMessage="Select your DriveLetter from A-Z. If the driveletter is not available it is automatically selected.")]
        [AllowEmptyString()]
        [Char]
        $DriveLetter = "^"
    )
    begin {
        $ErrorActionPreference = "STOP"
        Set-IWHardwareDetection -Stop
        [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.Path)) | Out-Null
    }

    process {
        try {
            $Device, $DriveLetter = Get-IWDevices | Start-IWPrepareDevice -DriveLetter $DriveLetter
            $Image = Mount-IWImage -ImagePath $ImagePath
            Robocopy.exe $("{0}:\" -f $Image.DriveLetter) $("{0}:\" -f $DriveLetter) /S /E /W:1 /R:2 /Log $(Get-PSFConfigValue -FullName ImageWriterEngine.Log.Path)
        } catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }
    }

    end {
        # Dismount-DiskImage -InputObject (Get-PSFConfigValue -FullName ImageWriterEngine.Session.DiskImage)
        $sessionPath = (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Path)
        if ($sessionPath) {
            Remove-Item -Path (Join-Path $sessionPath -Child (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Id)) -Force -Recurse
        }

        do {
            $result = Dismount-DiskImage -ImagePath (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
        }until(!$result)

        Set-IWHardwareDetection -Start
        $ErrorActionPreference = "Continue"
    }
}