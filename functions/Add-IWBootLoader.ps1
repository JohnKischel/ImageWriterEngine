function Add-IWBootLoader {
    [CmdletBinding()]
    param (

        [Parameter()]
        [char]
        $DriveLetter
    )

    begin {
        $ErrorActionPreference = "Stop"
        $mountPath = ([System.IO.Directory]::CreateDirectory(("{0}\..\mounts" -f $PSScriptRoot))).Fullname
        $storePath = Join-Path -Path "$mountPath\EFI" -ChildPath "Microsoft\Boot"

        $EfiSystemPartition = Get-Disk | Where-Object { $_.BusType -eq 'USB' } | Get-Partition | Where-Object { $_.Type -eq 'System' }

        try {
            Add-PartitionAccessPath -DiskNumber $EfiSystemPartition.Disknumber -PartitionNumber $EfiSystemPartition.PartitionNumber -AccessPath $mountPath
            [System.IO.Directory]::CreateDirectory($storePath)
        }
        catch {
            $dismount = ("mountvol.exe {0} /D" -f $mountPath)
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
    }

    end { 
        try {
            Remove-PartitionAccessPath -DiskNumber $EfiSystemPartition.Disknumber -PartitionNumber $EfiSystemPartition.PartitionNumber -AccessPath $mountPath
        }
        catch {
            Write-PSFMessage -Level Host -Message (("Could not Remove AccessPath: {0}" -f $mountPath)) -Tag "Bootloader"
        }
        finally{
            $dismount = ("mountvol.exe {0} /D" -f $mountPath)
            Invoke-Expression -Command $dismount | Out-Null
            Remove-Item -Path $mountPath -Force -Recurse |Out-Null
        }
    }
}