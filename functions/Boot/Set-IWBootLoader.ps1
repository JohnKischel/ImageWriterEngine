function Set-IWBootloader {
    param (
        # Reference to the volumedriveletter wich the bootloader should boot from.
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.Driveletter),

        # Identifier guid of the bootloader.
        [Parameter(ValueFromPipeline = $true)]
        [GUID]
        $Identifier,

        # Location of the BootManager store
        [Parameter()]
        [string]
        $StorePath = (Get-PSFConfigValue ImageWriterEngine.Session.StorePath)
    )

    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }

    # A bootloader is added. This process only works with winpes that are not modified and have its default name.
    process {
        try {
            bcdedit /store "$StorePath\BCD" /set '{bootmgr}' default "{$Identifier}" | Out-Null
            bcdedit /store "$StorePath\BCD" /set '{bootmgr}' displayorder "{$Identifier}" | Out-Null

            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" device "ramdisk=[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" path \windows\system32\boot\winload.efi | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" description  'Litetouch Boot [PE] (x64)' | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" osdevice ramdisk="[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" systemroot \Windows | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" bootmenupolicy Legacy | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" detecthal Yes | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" winpe Yes | Out-Null
            bcdedit /store "$StorePath\BCD" /set "{$Identifier}" ems Yes | Out-Null
            Write-PSFMessage -Level Verbose -Message ("Bootloader settings set.") -Tag "Bootloader"
        }
        catch {
            throw $_.Exception
        }
    }

    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}