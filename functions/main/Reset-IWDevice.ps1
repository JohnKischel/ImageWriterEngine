function Reset-IWDevice() {
    $Disks = Get-Disk | Where-Object { $_.BusType -like "usb" }
    if ($Disks) {
        foreach ($Disk in $Disks) {
            Write-Host ("-" * 50)
            Write-Host ("[ {0} ] - {1} - {2}" -f $Disk.Number, $Disk.FriendlyName, $Disk.Size)
            Write-Host ("-" * 50)
        }
            
        $DiskNumber = Read-Host "`nChoose your disk (number). Be careful the selected disk loses all data."
        Set-IWHardwareDetection -Stop
        $Device = Get-Disk $DiskNumber  | Clear-Disk -RemoveData -RemoveOEM -PassThru
        $Device | Set-Disk -PartitionStyle GPT
        $Device = $Device | New-Partition -UseMaximumSize -AssignDriveLetter
        $Device | Format-Volume -FileSystem NTFS -NewFileSystemLabel "IWE"
        Set-IWHardwareDetection -Start
    }
}