function Add-IWBootLoader {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $BootLoaderName = "ImageWriterEngine",

        # Location of the BootManager store
        [Parameter()]
        [string]
        $StorePath = "$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)\BCD"
    )

    $guid = bcdedit.exe /store $StorePath /create /d $BootLoaderName /application osloader
    $Identifier = [regex]::Matches($guid, "\w{0,8}-\w{0,4}-\w{0,4}-\w{0,4}-\w{0,12}").Value
    return $("{{{0}}}" -f $Identifier)
}