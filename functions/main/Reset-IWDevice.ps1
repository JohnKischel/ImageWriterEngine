function Reset-IWDevice() {
    $Disks = Get-Disk | Where-Object { $_.BusType -like "usb" }
    if ($Disks) {
        $Disks
        $DiskNumber = Read-Host "`nChoose your disk. Be careful the selected disk loses all data."
        $Device = Get-Disk $DiskNumber  | Clear-Disk -RemoveData -RemoveOEM -PassThru
        $Device | Set-Disk -PartitionStyle GPT
        $Device = $Device | New-Partition -UseMaximumSize -AssignDriveLetter
        $Device | Format-Volume -FileSystem NTFS -NewFileSystemLabel "IWE"
    }
}