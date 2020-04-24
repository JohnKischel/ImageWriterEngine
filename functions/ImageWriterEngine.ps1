function Start-ImageWriterEngine {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $ImagePath,

        [Parameter()]
        [Char]
        $DriveLetter
    )
    begin { }

    process {
        try {
            $Device, $DriveLetter = Get-IWDevices | Start-IWPrepareDevice -DriveLetter $DriveLetter
            $Image = Mount-IWImage -ImagePath $ImagePath
            Robocopy.exe $("{0}:\" -f $Image.DriveLetter) $("{0}:\" -f $DriveLetter) /S /E /W:1 /R:2
        }
        catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }
    }

    end { }
}

