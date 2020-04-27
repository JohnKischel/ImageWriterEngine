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
        [System.IO.Directory]::CreateDirectory(("{0}" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Log.Path))).FullName
        $logfile = $("{0}" -f (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Log.Path) -Child (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Id)))

    }

    process {
        try {
            $Device, $DriveLetter = Get-IWDevices | Start-IWPrepareDevice -DriveLetter $DriveLetter
            $Image = Mount-IWImage -ImagePath $ImagePath
            Robocopy.exe $("{0}:\" -f $Image.DriveLetter) $("{0}:\" -f $DriveLetter) /S /E /W:1 /R:2 /NP /LOG:$logfile
        } catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }

        Add-IWBootLoader -DriveLetter $DriveLetter
    }

    end {
        <#
        $sessionPath = (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Path)
        if (Test-Path $sessionPath) {
            Remove-Item -Path (Join-PSFPath $sessionPath -Child (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Id)) -Force -Recurse
        }
        #>
        do {
            $result = Dismount-DiskImage -ImagePath (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
        }until(!$result)

        Set-IWHardwareDetection -Start
        $ErrorActionPreference = "Continue"
    }
}