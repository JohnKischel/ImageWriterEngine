function Add-IWBootLoader {
    [CmdletBinding()]
    param (
        [Parameter()]
        [char]
        $DriveLetter
    )

    begin {
        [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.MountPath)) |Out-Null
        $EFIFilePath = Join-Path -Path (Get-PSFConfigValue ImageWriterEngine.Session.MountPath) -ChildPath "\EFI\Boot"
        $storePath = Join-Path -Path (Get-PSFConfigValue ImageWriterEngine.Session.MountPath) -ChildPath "EFI\Microsoft\Boot"
        #$EfiSystemPartition = Get-Disk | Where-Object { $_.BusType -eq 'USB' } | Get-Partition | Where-Object { $_.Type -eq 'System' }

        try {
            Get-IWDevicePartitions -DriveLetter $DriveLetter
            Add-PartitionAccessPath -DiskNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).Disknumber -PartitionNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).EFIPartitionNumber -AccessPath (Get-PSFConfigValue ImageWriterEngine.Session.MountPath)
            [System.IO.Directory]::CreateDirectory($EFIFilePath) |Out-Null
            [System.IO.Directory]::CreateDirectory($storePath) |Out-Null
        } catch {
            $dismount = ("mountvol.exe {0} /D" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))
            Invoke-Expression -Command $dismount
        }
    }

    process {
        
        # -----------------------------------------------------
        # Creating BootManager
        # -----------------------------------------------------

        bcdedit.exe /createstore "$storePath\BCD" | Out-Null
        Write-PSFMessage -Level Host -Message ("Create store {0}\BCD" -f $storePath) -Tag "Bootloader" 
        bcdedit.exe /store "$storePath\BCD" /create '{bootmgr}' /d "Microsoft Boot Manager" | Out-Null
        Write-PSFMessage -Level Host -Message ("Create Microsoft Boot Manager.") -Tag "Bootloader"
        $guid = bcdedit.exe /store "$storePath\BCD" /create /d "Windows 10" /application osloader #{4968d07a-d93c-11e9-a36e-eccd6ddc4741}
        $match = [regex]::Matches($guid, "\w{0,8}-\w{0,4}-\w{0,4}-\w{0,4}-\w{0,12}").Value
        $match = $("{{{0}}}" -f $match)
        Write-PSFMessage -Level Host -Message ("Bootloader entry: {0}" -f $match) -Tag "Bootloader"

        bcdedit /store "$storePath\BCD" /set '{bootmgr}' default $match | Out-Null
        bcdedit /store "$storePath\BCD" /set '{bootmgr}' description 'Windows Boot Manager' | Out-Null
        bcdedit /store "$storePath\BCD" /set '{bootmgr}' flightsigning Yes | Out-Null
        bcdedit /store "$storePath\BCD" /set '{bootmgr}' displayorder $match | Out-Null
        Write-PSFMessage -Level Host -Message ("Bootloader description, flightsigning, displayorder set.") -Tag "Bootloader"

        # -----------------------------------------------------
        # Creating RamDisk / BootLoader
        # -----------------------------------------------------

        bcdedit /store "$storePath\BCD" /create '{ramdiskoptions}' /d "ramdiskoption" | Out-Null
        bcdedit /store "$storePath\BCD" /set '{ramdiskoptions}' ramdisksdidevice partition="$DriveLetter`:" | Out-Null
        bcdedit /store "$storePath\BCD" /set '{ramdiskoptions}' ramdisksdipath \boot\boot.sdi | Out-Null
        Write-PSFMessage -Level Host -Message ("Ramdiskoptions created.") -Tag "Bootloader"
        # Bootloader
        # bcdedit /store BCD /set '{default}' identifier '{default}'
        bcdedit /store "$storePath\BCD" /set '{default}' device "ramdisk=[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
        Write-PSFMessage -Level Host -Message ("{0}:\Deploy\Boot\LiteTouchPE_x64.wim" -f $DriveLetter) -Tag "Bootloader"
        bcdedit /store "$storePath\BCD" /set '{default}' path \windows\system32\boot\winload.efi | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' description  'Litetouch Boot [PE] (x64)' | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' osdevice ramdisk="[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' systemroot \Windows | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' bootmenupolicy Legacy | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' detecthal Yes | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' winpe Yes | Out-Null
        bcdedit /store "$storePath\BCD" /set '{default}' ems Yes | Out-Null
        Write-PSFMessage -Level Host -Message ("path description, osdevice, systemroot, bootmenupolicy,detecthal,winpe,ems set.") -Tag "Bootloader"

        # Copy EfiFile to EfiPartition
        $logfile = $("{0}" -f (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath) -Child EFILog))
        Robocopy ("{0}:\EFI\Boot\" -f $DriveLetter) $EFIFilePath bootx64.efi /S /E /W:1 /R:2 /NP /LOG+:$logfile | Out-Null
    }

    end { 
        try {
            Remove-PartitionAccessPath -DiskNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).Disknumber -PartitionNumber (Get-PSFConfigValue ImageWriterEngine.Session.Device).EFIPartitionNumber -AccessPath (Get-PSFConfigValue ImageWriterEngine.Session.MountPath)
        } catch {
            Write-PSFMessage -Level Host -Message (("Could not Remove AccessPath: {0}" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))) -Tag "Bootloader"
        } finally {
            $dismount = ("mountvol.exe {0} /D" -f (Get-PSFConfigValue ImageWriterEngine.Session.MountPath))
            Invoke-Expression -Command $dismount | Out-Null
            Remove-Item -Path (Get-PSFConfigValue ImageWriterEngine.Session.MountPath) -Force -Recurse | Out-Null
        }
    }
}