function Add-IWBootLoader {
    [CmdletBinding()]
    param (
        [Parameter()]
        [char]
        $DriveLetter
    )

    begin {
        
    }

    process {
        
        # -----------------------------------------------------
        # Creating BootManager
        # -----------------------------------------------------

        ######## bcdedit /store "$storePath\BCD" /set '{bootmgr}' default $match | Out-Null
        
        Write-PSFMessage -Level Host -Message ("Bootloader description, flightsigning, displayorder set.") -Tag "Bootloader"

        # -----------------------------------------------------
        # Creating RamDisk / BootLoader
        # -----------------------------------------------------

        
        Write-PSFMessage -Level Host -Message ("Ramdiskoptions created.") -Tag "Bootloader"
        # Bootloader
        # bcdedit /store BCD /set '{default}' identifier '{default}'
        

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