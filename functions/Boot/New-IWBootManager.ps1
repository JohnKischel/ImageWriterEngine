function New-IWBootManager {

    param(
        [Parameter()]
        [string]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.Driveletter),
        # Location of the BootManager store
        [Parameter()]
        [string]
        $StorePath = (Get-PSFConfigValue ImageWriterEngine.Session.StorePath),

        [Parameter()]
        [string]
        $EFIPath = (Get-PSFConfigValue ImageWriterEngine.Session.EFIPath)
    )
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }
    
    process {
        if (-not ([System.IO.File]::Exists("$StorePath\BCD"))) {
            [System.IO.Directory]::CreateDirectory($StorePath) | Out-Null
            [System.IO.Directory]::CreateDirectory($EFIPath) | Out-Null
        }

        bcdedit.exe /createstore "$StorePath\BCD" | Out-Null
        Write-PSFMessage -Level Host -Message "$StorePath\BCD" -Tag "Bootloader" 
        bcdedit.exe /store "$StorePath\BCD" /create '{bootmgr}' /d "Microsoft Boot Manager" | Out-Null
        Write-PSFMessage -Level Host -Message ("Create Microsoft Boot Manager.") -Tag "Bootloader"

        bcdedit /store "$StorePath\BCD" /set '{bootmgr}' description 'Windows Boot Manager' | Out-Null
        bcdedit /store "$StorePath\BCD" /set '{bootmgr}' flightsigning Yes | Out-Null
        bcdedit /store "$StorePath\BCD" /set '{bootmgr}' displayorder $match | Out-Null
    }
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}