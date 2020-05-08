function Copy-IWImage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
        [ValidateNotNullOrEmpty()]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $ImageDriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).DriveLetter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('.+\.txt')]
        [string]
        $LogFile = $("{0}" -f (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath) -Child "ImageCopy.txt"))
    )

    process {
        Start-Job -ScriptBlock {
            param($ImageDriveLetter, $LogFile, $DriveLetter)
            Robocopy.exe $("{0}:\" -f $ImageDriveLetter) $("{0}:\" -f $DriveLetter) /S /E /XO /W:1 /R:2 /NP /LOG:$logfile | Out-Null 
        } -ArgumentList $ImageDriveLetter, $LogFile, $DriveLetter -Name ImageCopy | Out-Null
    }

    end { }
}