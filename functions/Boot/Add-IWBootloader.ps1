function Add-IWBootLoader {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $BootLoaderName = "ImageWriterEngine",

        # Location of the BootManager store
        [Parameter()]
        [string]
        $StorePath = "$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)\BCD",

        # Location of the BootManager store
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.Driveletter)
    )
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }

    process {
        $guid = bcdedit.exe /store $StorePath /create /d $BootLoaderName /application osloader
        $Identifier = [regex]::Matches($guid, "\w{0,8}-\w{0,4}-\w{0,4}-\w{0,4}-\w{0,12}").Value
        Write-PSFMessage -Level Verbose -Message ("Bootloader added with identifier {0}" -f $Identifier) -Tag "Bootloader"
        return $Identifier
    }

    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}