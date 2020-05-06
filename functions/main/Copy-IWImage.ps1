function Copy-IWImage
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),

        [Parameter()]
        [string]
        $ImageDriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).DriveLetter,

        [Parameter()]
        [string]
        $LogFile = $("{0}" -f(Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath) -Child "ImageCopy.txt"))
    )

    Start-Job -ScriptBlock {
        param($ImageDriveLetter, $LogFile, $DriveLetter)
        Robocopy.exe $("{0}:\" -f $ImageDriveLetter) $("{0}:\" -f $DriveLetter) /S /E /W:1 /R:2 /NP /LOG:$logfile | Out-Null 
    } -ArgumentList $ImageDriveLetter,$LogFile,$DriveLetter -Name ImageCopy | Out-Null
}