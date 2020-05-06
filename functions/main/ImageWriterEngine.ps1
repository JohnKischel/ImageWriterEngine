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

        $ErrorActionPreference = "STOP"

        #Create file folder structure.
        [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.Path)) | Out-Null
        [System.IO.Directory]::CreateDirectory(("{0}" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath))) | Out-Null        
        
        Get-IWDevices -DriveLetter $DriveLetter
        Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DiskImagePath' -Value $ImagePath
        
        # Stop Hardware detection service.
        Set-IWHardwareDetection -Stop

        # Remove previous jobs.
        Get-Job -Name ImageCopy -ErrorAction 0 | Remove-Job -ErrorAction 0 -Force
    }

    process {
        try {
            #Mount Image and and prepare the device. If the device is already prepared this step skips.
            Mount-IWImage
            if (-not (Get-IWDevicePartitions -DriveLetter $DriveLetter)) {
                $DriveLetter = Start-IWPrepareDevice
            }
            
            # Copy image to selected device.
            Copy-IWImage
        }
        catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }
        
        do {
            # Get-IWProgress -DriveLetter 
            $Size = (Get-Volume $DriveLetter) | Select-Object Size, SizeRemaining
            $output = ($Size.Size - $Size.SizeRemaining) / 1GB
            if ($output -ne $lastoutput) {
                Write-Host ("{0}" -f ($Size.Size - $Size.SizeRemaining) / 1GB)
                Start-Sleep -Seconds 1
                $lastoutput = $output
            }
        }while (-not ((Get-Job -Name "ImageCopy").State -eq "Completed"))
        
        try {
            # Write Bootmanager,Bootlader,Ramdisk and EFIfile to the EFI Partition.
            Initialize-IWBootConfigurationData -DriveLetter $DriveLetter
        }
        catch {
            $_.Exception
        }
    }

    end {
        # Dismount mounted ISO
        Dismount-IWImage -ImagePath (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)

        # Start Hardware detection service.
        Set-IWHardwareDetection -Start

        # Cleanup created jobs.
        Get-Job -Name ImageCopy | Remove-Job -Force
        $ErrorActionPreference = "Continue"
    }
}