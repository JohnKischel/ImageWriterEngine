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
        try {
            Get-Job -Name ImageCopy -ErrorAction 0 | Remove-Job -ErrorAction 0 -Force
        }
        catch {
            'Tried to remove previous jobs.'
        }
    }

    process {
        Get-IWDevices -DriveLetter $DriveLetter | Out-Null
        #Mount Image and and prepare the device. If the device is already prepared this step is skipped.
        Mount-IWImage | Out-Null

        # if the image size exceeds the drivesize an error is thrown.
        if (-not ((Get-PSFConfigValue ImageWriterEngine.Session.DevicePartitionInputObject).Size -le (Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).Size)) {
            Dismount-IWImage
            throw 'Insufficient Memory. More storage is needed.'
        }

        if (-not (Get-IWDevicePartitions -DriveLetter $DriveLetter)) {
            $DriveLetter = Get-IWDevices -DriveLetter $DriveLetter | Start-IWPrepareDevice
        }
            
        # Copy image to selected device.
        Copy-IWImage

        
        do {
            $Size = (Get-Volume $DriveLetter) | Select-Object Size, SizeRemaining
            $Output = ($Size.Size - $Size.SizeRemaining) / 1GB
            if ($Output -ne $Lastoutput) {
                # Get-IWProgress
                Write-Host  ("{0} / {1}" -f $Output, $Size)
                Start-Sleep -Seconds 1
                $Lastoutput = $Output
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

        # Cleanup Session
        Remove-Item -Path ("{0}\*" -f (Get-PSFConfigValue ImageWriterEngine.Session.Path)) -Force -Recurse -ErrorAction 0
        $ErrorActionPreference = "Continue"
    }
}