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
        $DriveLetter = Test-DriveLetter -DriveLetter $DriveLetter
        if (-not (ValidatePath -Path $ImagePath)) { throw "Could not validate imagepath." }
        if (-not (ValidatePath -Path $ConfigFile)) { throw "Could not validate configfile." }
        
        # Load the config file
        Get-IWConfig -ConfigFile $ConfigFile -SetAsEnvironmentVariable
        $Script:IWConfig.image.imagepath = $ImagePath

        # Dismount previous images.
        if (Dismount-IWImage -ImagePath $Script:IWConfig.image.imagepath) { $Script:IWConfig.image.ismounted = $false }
        
        # Stop Hardware detection service.
        Set-IWHardwareDetection -Stop

        # Remove previous jobs.
        try { Get-Job -Name ImageCopy -ErrorAction 0 | Remove-Job -ErrorAction 0 -Force } catch { 'Could not remove previous jobs.' }
    }

    process {

        if ([string]::IsNullOrEmpty($Script:IWConfig.workingdirectory)) {
            $Script:IWConfig.workingdirectory = Join-Path -Path $script:ModuleRoot -ChildPath "bin/session"
        }

        if ([string]::IsNullOrEmpty($Script:IWConfig.logging.logpath)) {
            $Script:IWConfig.logging.logpath = Join-Path -Path $script:ModuleRoot -ChildPath "bin/session/log"
        }

        # Remove the -Secure to select other drives than usb. Get-IWDevices return an array.
        $Script:IWConfig.device.driveletter, $Script:IWConfig.device.volumeobject = Get-IWDevice -DriveLetter $DriveLetter -Secure

        # Mount Image
        if ($Script:IWConfig.image.ismounted -eq $false) {
            $Script:IWConfig.image.driveletter, $Script:IWConfig.image.volumeobject = Mount-IWImage -ImagePath $Script:IWConfig.image.imagepath -ignoreWinPE
        }
        
        # If the image size exceeds the drivesize an error is thrown.
        if (-not ($Script:IWConfig.device.volumeobject | Get-Partition).Size -ge $Script:IWConfig.device.constraints.minSize ) {
            Dismount-IWImage
            Start-IWPrepareDevice -DriveLetter $Script:IWConfig.device.driveletter -InputObject $Script:IWConfig.device.volumeobject
            New-IWNotification -Message ("Preparing volume {0}" -f $Script:IWConfig.image.driveletter)
            # throw 'Not enough available capacity.'
        }

        if ((Get-IWDevicePartitions -DriveLetter $Script:IWConfig.device.driveletter) -eq 1) {
            Write-Warning -Message "Attention you are forced to delete your device. Please read the following steps carefully. "
            Reset-IWDevice
            $Script:IWConfig.device.partitions = Start-IWPrepareDevice -DriveLetter $Script:IWConfig.device.driveletter -InputObject $Script:IWConfig.device.volumeobject
        }
        # Copy image to selected device.
        New-IWNotification -Message ("Started. Transfer image.")
        if (-not $Script:IWConfig.device.newdriveletter) {
            $Script:IWConfig.device.newdriveletter = Get-IWDevice -NextDriveLetter
        }

        Copy-IWImage -DriveLetter $Script:IWConfig.device.driveletter -ImageDriveLetter $Script:IWConfig.image.driveletter -LogFile (Join-Path -Path $Script:IWConfig.logging.logpath -ChildPath $Script:IWConfig.logging.defaultfilename) | Out-Null

        do {
            if (-not($NoProgress.IsPresent)) {
                #Get-IWProgress -DriveLetter $Script:IWConfig.device.newdriveletter
                Write-Host "." -NoNewline ; Start-Sleep -Seconds 5
            }
        }while (-not ((Get-Job -Name "ImageCopy").State -eq "Completed"))
        
        try {
            # Write Bootmanager,Bootlader,Ramdisk and EFIfile to the EFI Partition.

            # Bootloader preparation
            $options = @{
                DriveLetter     = $Script:IWConfig.device.newdriveletter
                Disknumber      = $Script:IWConfig.device.partitions.disknumber
                Partitionnumber = $Script:IWConfig.device.partitions.efipartition
                MountPath       = $Script:IWConfig.mountpath
            }

            if ((Mount-IWEFIPartition @options) -eq 0) {
                $Script:IWConfig.device.bootloader.ismounted = $true
            } else {
                $Script:IWConfig.device.bootloader.ismounted = $false
            }
            # Add log "Invoke Add-IWEFile"
            Add-IWEFIFile -Source $Script:IWConfig.image.driveletter -Destination (Join-Path $Script:IWConfig.bootloader.mountpath -ChildPath $Script:IWConfig.bootloader.efipath)

            # Add log "Invoke New-IWBootManager"
            New-IWBootManager  -DriveLetter $DriveLetter -Force

            # Add log "Invoke Add-IWRamdisk"
            Add-IWRamdisk -DriveLetter $DriveLetter

            # Add log "Invoke Add-IWBootLoader"
            $Identifier = Add-IWBootLoader -DriveLetter $DriveLetter
            
            # Add log "Invoke Set-IWBootloader"
            Set-IWBootloader -DriveLetter $DriveLetter -Identifier $Identifier
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