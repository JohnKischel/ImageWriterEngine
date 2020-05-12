
function Add-IWRamdisk {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $StorePath = "$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)\BCD",

        [Parameter()]
        [char]
        [ValidatePattern('[A-Za-z]')]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)
    )

    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }

    process {
        try {
            bcdedit /store $StorePath /create '{ramdiskoptions}' /d "ramdiskoption" | Out-Null
            bcdedit /store $StorePath /set '{ramdiskoptions}' ramdisksdidevice partition="$DriveLetter`:" | Out-Null
            bcdedit /store $StorePath /set '{ramdiskoptions}' ramdisksdipath \boot\boot.sdi | Out-Null
            Write-PSFMessage -Level Verbose -Message ("RamDisk added.") -Tag "Bootloader"
        }
        catch {
            throw $_.Exception 
        }

    }
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}