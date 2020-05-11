function Start-ImageWriterEngine {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [String]
        $ImagePath,

        [Parameter(HelpMessage = "Select your DriveLetter from A-Z. Format example: Valid(C,D,E) Not valid (C:\,D:\,E:\ or C:,D:,E:")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('[A-Za-z]')]
        [Char]
        $DriveLetter
    )
    begin {

        $ErrorActionPreference = "STOP"

        #Create file folder structure.
        [System.IO.Directory]::CreateDirectory((Get-PSFConfigValue ImageWriterEngine.Session.Path)) | Out-Null
        [System.IO.Directory]::CreateDirectory(("{0}" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Session.LogPath))) | Out-Null        

        Set-PSFConfig -Name 'ImageWriterEngine.Session.DiskImagePath' -Value $ImagePath

        # Stop Hardware detection service.
        Set-IWHardwareDetection -Stop
        
        # Remove previous jobs.
        try { Get-Job -Name ImageCopy -ErrorAction 0 | Remove-Job -ErrorAction 0 -Force } catch { 'Tried to remove previous jobs.' }
    }

    process {
        # Remove the -Secure to select other drives than usb.
        Get-IWDevices -DriveLetter $DriveLetter -Secure | Out-Null

        # Mount Image
        Mount-IWImage | Out-Null

        # if the image size exceeds the drivesize an error is thrown.
        if (-not ((Get-PSFConfigValue ImageWriterEngine.Session.DeviceInputObject).Size -ge (Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).Size)) {
            Dismount-IWImage
            throw 'Not enough available capacity.'
        }

        if (-not (Get-IWDevicePartitions -DriveLetter $DriveLetter)) {
            Get-IWDevices -DriveLetter $DriveLetter | Start-IWPrepareDevice
        }
        # Copy image to selected device.
        Copy-IWImage

        
        do {
            Get-IWProgress
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

        # Cleanup Session
        # Remove-Item -Path ("{0}\*" -f (Get-PSFConfigValue ImageWriterEngine.Session.Path)) -Force -Recurse -ErrorAction 0
        $ErrorActionPreference = "Continue"
    }
}