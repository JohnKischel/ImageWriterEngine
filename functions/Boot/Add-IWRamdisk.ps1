
function Add-IWRamdisk {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $StorePath = "$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)\BCD"
    )

    bcdedit /store $StorePath /create '{ramdiskoptions}' /d "ramdiskoption" | Out-Null
    bcdedit /store $StorePath /set '{ramdiskoptions}' ramdisksdidevice partition="$DriveLetter`:" | Out-Null
    bcdedit /store $StorePath /set '{ramdiskoptions}' ramdisksdipath \boot\boot.sdi | Out-Null
}