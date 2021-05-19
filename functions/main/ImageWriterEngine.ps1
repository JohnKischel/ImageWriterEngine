function Start-ImageWriterEngine {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, HelpMessage = "Path of the isofile.")]
        [String]
        $ImagePath,

        [Parameter(Position = 1, HelpMessage = "Select your DriveLetter from A-Z. Format example: Valid(C,D,E,C:\,D:\,E:\,C:,D:,E:")]
        [ValidateNotNullOrEmpty()]
        $DriveLetter,

        [Parameter(Position = 2, HelpMessage = 'Location of the ConfigFile')]
        [string]
        $ConfigFile = "config.yaml",

        [Parameter(Position = 3, HelpMessage = 'Show progress while installing consider using verbose.')]
        [switch]
        $NoProgress
    )

    begin {

        $ErrorActionPreference = "STOP"

        # Validate inputs
        Test-DriveLetter -DriveLetter $DriveLetter
        if (-not (ValidatePath -Path $ImagePath)) { exit }
        if (-not (ValidatePath -Path $ConfigFile)) { exit }
        
        # Load the config file
        Get-IWConfig -ConfigFile $ConfigFile -SetAsEnvironmentVariable
        $Script:IWConfig.image.imagepath = $ImagePath

        # Dismount previous images.
        if (Dismount-IWImage -ImagePath $ImagePath) { $Script:IWConfig.image.mounted = $false }
        
        # Stop Hardware detection service.
        Set-IWHardwareDetection -Stop

        # Remove previous jobs.
        try { Get-Job -Name ImageCopy -ErrorAction 0 | Remove-Job -ErrorAction 0 -Force } catch { 'Tried to remove previous jobs.' }
    }

    process {

        if ([string]::IsNullOrEmpty($Script:IWConfig.workingdirectory)) {
            $Script:IWConfig.workingdirectory = Join-Path -Path $Script:ModuleRoot -ChildPath "bin/session"
        }

        if ([string]::IsNullOrEmpty($Script:IWConfig.logging.logpath)) {
            $Script:IWConfig.logging.logpath = Join-Path -Path $Script:ModuleRoot -ChildPath "bin/log"
        }

        # Remove the -Secure to select other drives than usb. Get-IWDevices return an array.
        $Script:IWConfig.device.driveletter, $Script:IWConfig.device.volumeobject = Get-IWDevice -DriveLetter $DriveLetter -Secure

        # Mount Image
        if ($Script:IWConfig.image.mounted -eq $false) {
            $Script:IWConfig.image.driveletter, $Script:IWConfig.image.volumeobject = Mount-IWImage -ImagePath $Script:IWConfig.image.imagepath -ignoreWinPE
        }
        
        # If the image size exceeds the drivesize an error is thrown.
        if (-not ($Script:IWConfig.device.volumeobject | Get-Partition).Size -ge $Script:IWConfig.device.constraints.minSize ) {
            Dismount-IWImage
            Get-IWDevice -DriveLetter $DriveLetter | Start-IWPrepareDevice
            New-IWNotification -Message ("Preparing volume {0}" -f $DriveLetter)
            # throw 'Not enough available capacity.'
        }

        if (-not (Get-IWDevicePartitions -DriveLetter $DriveLetter)) {
            Get-IWDevice -DriveLetter $DriveLetter | Start-IWPrepareDevice
        }

        # Copy image to selected device.
        New-IWNotification -Message ("Started. Transfer image.")
        Copy-IWImage

        do {
            if (-not($NoProgress.IsPresent)) {
                Get-IWProgress
            }
        }while (-not ((Get-Job -Name "ImageCopy").State -eq "Completed"))
        
        try {
            # Write Bootmanager,Bootlader,Ramdisk and EFIfile to the EFI Partition.
            Initialize-IWBootConfigurationData -DriveLetter $DriveLetter
        } catch {
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
        New-IWNotification -Message ("Finished. You can now remove the device.")
        return 0
    }
}