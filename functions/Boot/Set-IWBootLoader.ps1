function Set-IWBootloader {
    param (
        # Reference to the volumedriveletter wich the bootloader should boot from.
        [Parameter()]
        [char]
        $DriveLetter,

        # Identifier guid of the bootloader.
        [Parameter(ValueFromPipeline=$true)]
        [GUID]
        $Identifier,

        # Location of the BootManager store
        [Parameter()]
        [string]
        $StorePath = "$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)\BCD"
    )

    bcdedit /store $StorePath /set '{bootmgr}' default "{$Identifier}" | Out-Null
    bcdedit /store $StorePath /set '{bootmgr}' displayorder "{$Identifier}" | Out-Null

    bcdedit /store $StorePath /set "{$Identifier}" device "ramdisk=[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" path \windows\system32\boot\winload.efi | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" description  'Litetouch Boot [PE] (x64)' | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" osdevice ramdisk="[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" systemroot \Windows | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" bootmenupolicy Legacy | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" detecthal Yes | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" winpe Yes | Out-Null
    bcdedit /store $StorePath /set "{$Identifier}" ems Yes | Out-Null
}