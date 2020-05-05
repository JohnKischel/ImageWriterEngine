function Start-ImageWriterEngine {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [String]
        $ImagePath,

        [Parameter(HelpMessage = "Select your DriveLetter from A-Z. Format example: Valid(C,D,E) Not valid (C:\,D:\,E:\ or C:,D:,E:")]
        [ValidateNotNullOrEmpty()]
        [Char]
        $DriveLetter
    )
    begin {
        $ErrorActionPreference ="STOP"       
        # Remove jobs
        Get-Job -Name ImageCopy -ErrorAction 0 | Remove-Job -ErrorAction 0 -Force
        Set-IWHardwareDetection -Stop
        [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.Path)) | Out-Null
        [System.IO.Directory]::CreateDirectory(("{0}" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath))).FullName | Out-Null
        $logfile = $("{0}" -f (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath) -Child "Image.txt"))
    }

    process {
        try {
            $Image = Mount-IWImage -ImagePath $ImagePath
            if (-not (Get-IWDevicePartitions -DriveLetter $DriveLetter)) {
                $DriveLetter = Get-IWDevices -DriveLetter $DriveLetter | Start-IWPrepareDevice
            }
            
            # Copy image to device
            Start-Job -ScriptBlock {
                param($Image, $logfile, $DriveLetter)
                Robocopy.exe $("{0}:\" -f $Image.DriveLetter) $("{0}:\" -f $DriveLetter) /S /E /W:1 /R:2 /NP /LOG:$logfile | Out-Null 
            } -ArgumentList $Image, $logfile, $DriveLetter -Name ImageCopy | Out-Null
        }
        catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }

        do {
            Get-IWProgress -DriveLetter $DriveLetter
            Start-Sleep -Seconds 1
        }while (!(Get-Job -Name "ImageCopy").State -eq "Completed")
        # Mount EFIpartition, create store and copy EFIFile.
        try {
            Initialize-IWBootConfigurationData -DriveLetter $DriveLetter
        }
        catch {
            $_.Exception
        }
    }

    end {
        do {
            # Cleanup mounted Disks
            $result = Dismount-DiskImage -ImagePath (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
        }until(!$result)
        Get-Job -Name ImageCopy | Remove-Job -Force
        Set-IWHardwareDetection -Start
        $ErrorActionPreference = "Continue"
    }
}