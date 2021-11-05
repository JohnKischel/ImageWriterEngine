. $PSScriptRoot\BootFactory.ps1
. $PSScriptRoot\DeviceFactory.ps1

#Get the selected device
$dc = [DeviceCollectorByDiskNumber]::new(1)

# Create all partitions.
$wp = [WindowsPartition]::new('R',50GB)
$ep = [EfiPartition]::new()
$mp = [MSRPartition]::new()
$parts = $wp,$ep,$mp

# Create a DeviceFactory to clear the device and create all overloaded partitions.
$df = [DeviceFactory]::new($dc,$parts)
$df.clear_device()
$df.create_partition()

# Mount the desired ISO
$im = [ISOImage]::new("C:\tmp\StandardImage_30062019_1929.iso")
$im.mount()
# Write data from the mounted iso to the selected device.
$i2dw = [ISO2DiskWriter]::new($im.get_drive_letter(),$dc.get_drive_letter())
$i2dw.write_data('C:\Windows\Logs\ImageWriterEngine.log')

# Wait until the copy job is finished then unmount
Get-Job -Name "ImageCopy" -ErrorAction 0 |Remove-Job -ErrorAction 0
do {
        Write-Host "." -NoNewline ; Start-Sleep -Seconds 5
}while (-not ((Get-Job -Name "ImageCopy").State -eq "Completed"))


# Mount the system partition to copy the bootloader
$pap = [PartitionAccessPath]::new($dc,'C:\tmp\mnt')
$pap.mount()


$SOURCEEFIFILE = (Get-ChildItem -Path ('{0}:\EFI\Boot' -f $im.ImageObject.DriveLetter) -Filter 'bootx64.efi' -Recurse).FullName
$DESTINATIONEFIFILE = Join-Path -Path $pap.MountPath -ChildPath '\EFI\Boot'

$f2pw = [EFIFile2PartitionWriter]::new($SOURCEEFIFILE, $DESTINATIONEFIFILE)
$f2pw.write_data()

# BOOTLOADER PART
$s = [Store]::new('C:\tmp\BCD')
$s.create()

$bm = [BootManager]::new($s,"{bootmgr}","ImageWriterBootManager")
$bm.create()

$bl = [BootLoader]::new($s,'ImageWriterEngineLoader')
$bl.create()

$rm = [RAMDisk]::new($s)
$rm.create()
$rm.set($dc.get_drive_letter())

$bl.set_default()
$bl.set_displayorder()
$bl.set_device($dc.get_drive_letter())
$bl.set_path()
$bl.set_description()
$bl.set_osdevice($dc.get_drive_letter())
$bl.set_systemroot()
$bl.set_bootmenupolicy()
$bl.set_detecthal()
$bl.set_winpe()
$bl.set_ems()

$STOREPATH = Join-Path -Path $pap.MountPath -ChildPath 'EFI\Microsoft\Boot\'
$s2pw = [Store2PartitionWriter]::new($s.Path,$STOREPATH)
$s2pw.write_data()

$pap.unmount()
$im.unmount()
