####################################################
# DeviceFactory Classes
####################################################
#region DeviceFactory
class DeviceFactory {

    [DeviceCollector] $Device
    [Partition[]]$Partition
    [bool] $isCleared = 1

    DeviceFactory([DeviceCollector]$Device,[Partition[]]$Partition){
        $this.Device = $Device
        $this.Partition = $Partition
    }

    [Partition[]]get_partition(){
        return $this.Partition
    }

    clear_device(){
            Clear-Disk -RemoveData -Confirm:$false -InputObject $this.Device.VolumeObject -RemoveOEM -ErrorAction Stop
            $this.isCleared = 0
    }

    set_partition_style($type){
        try {
            if(-not $this.Device.VolumeObject.is_gpt()){
                    if($this.isCleared -ne 0){
                        $this.clear_device()
                    }
                Set-Disk -PartitionStyle $type -InputObject $this.Device.VolumeObject -ErrorAction Stop
            }
            }catch {
                    throw "Failure while setting the Device to GPT."
            }
    }

    create_partition(){
        $this.Partition | ForEach-Object{
            $_.create_partition($this.Device)
        }     
    }

}
#endregion

####################################################
# DeviceCollector Classes
####################################################
#region DeviceCollector
class DeviceCollector{
    [Object] $VolumeObject

    [bool] is_gpt(){
        if($this.VolumeObject.PartitionStyle -eq 'GPT'){
            return $true
        }
        return $false
    }

    [string] get_drive_letter(){
        return ($this.VolumeObject | Get-Partition | Where-Object{ $_.Type -eq 'Basic'} ).DriveLetter
    }

    [object] get_partition(){
        return $this.VolumeObject |Get-Partition
    }

    [object] get_partitionByType($type){
        $partitions = $this.VolumeObject |Get-Partition
        return ($partitions | Where-Object{$_.Type -eq $type} | Select-Object PartitionNumber, DiskNumber)
    }
}

class DeviceCollectorByDriveLetter:DeviceCollector{
    DeviceCollectorByDriveLetter($DriveLetter){
        $this.VolumeObject = Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk
    }
}

class DeviceCollectorByDiskNumber:DeviceCollector{
    DeviceCollectorByDiskNumber($DiskNumber){
        $this.VolumeObject = Get-Disk -Number $DiskNumber -ErrorAction 0
    }
}
#endregion

####################################################
# Partition Classes
####################################################
#region Partition
class Partition{

    $Size

    create_partition(){}
    [string] get_drive_letter(){
        return $this.DriveLetter
    }
}

class WindowsPartition:Partition{

    $FileSystem='NTFS'
    $NewFileSystemLabel='BOOT'
    $DriveLetter
    $GptType ='{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

    WindowsPartition($DriveLetter,$Size){
        $this.DriveLetter = $DriveLetter
        $this.Size = $Size
    }

    WindowsPartition($FileSystem,$NewFileSystemLabel,$DriveLetter,$Size,$GptType){
        $this.FileSystem = $FileSystem
        $this.NewFileSystemLabel = $NewFileSystemLabel
        $this.DriveLetter = $DriveLetter
        $this.Size = $Size
        $this.GptType = $GptType
    }

    create_partition($Device){
        New-Partition -InputObject $Device.VolumeObject -Size $this.Size -GptType $this.GptType -DriveLetter $this.DriveLetter  -ErrorVariable Err -ErrorAction Stop | Out-Null
        Format-Volume -FileSystem 'NTFS' -NewFileSystemLabel $this.NewFileSystemLabel -DriveLetter $this.DriveLetter  -Force | Out-Null
    }
}

class EfiPartition:Partition{
    $FileSystem='FAT32'
    $NewFileSystemLabel='System'
    $Size = 100MB
    $GptType ='{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
    $IsActive = $false
    $IsHidden = $true

    EfiPartition(){

    }

    EfiPartition($FileSystem,$NewFileSystemLabel,$Size,$GptType){
        $this.FileSystem = $FileSystem
        $this.NewFileSystemLabel = $NewFileSystemLabel
        $this.Size = $Size
        $this.GptType = $GptType
    }

    create_partition($Device){
        New-Partition -InputObject $Device.VolumeObject -Size $this.Size -GptType $this.GptType -IsActive:($this.IsActive) -IsHidden:($this.IsHidden) -ErrorAction Stop |`
        Format-Volume -FileSystem $this.FileSystem -NewFileSystemLabel $this.NewFileSystemLabel -Confirm:$false -ErrorAction Stop | Out-Null
    }
}

class MSRPartition:Partition{

    $GptType='{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
    $Size=128MB
    $IsActive = $false
    $IsHidden = $true

    MSRPartition(){
    }

    MSRPartition($Size,$GptType,$IsActive,$IsHidden){
        $this.Size = $Size
        $this.GptType = $GptType
        $this.IsActive = ,$IsActive
        $this.IsHidden = ,$IsHidden
    }

    create_partition($Device){
        New-Partition -InputObject $Device.VolumeObject -Size $this.Size -GptType $this.GptType -IsActive:($this.IsActive) -IsHidden:($this.IsHidden) -ErrorAction Stop | Out-Null
    }

}
#endregion

####################################################
# IMountProcessor
####################################################
#region IMountProcessor
class IMountProcessor{
    unmount(){}
    mount(){}
}

class ISOImage:IMountProcessor{

    $ImagePath
    $ImageObject

    ISOImage($ImagePath){
        $this.ImagePath = $ImagePath
    }

    mount(){
        $this.unmount()
        $this.ImageObject = Get-DiskImage $this.ImagePath | Mount-DiskImage -PassThru | Get-Volume
    }

    unmount(){
        Dismount-DiskImage -ImagePath  $this.ImagePath | Out-Null
        $this.ImageObject = $null
    }

    [string] get_drive_letter(){
        return $this.ImageObject.DriveLetter
    }
}

class PartitionAccessPath:IMountProcessor{

    $Device
    $MountPath
    $PartitionType = "System"

    PartitionAccessPath([DeviceCollector]$Device,$MountPath,$PartitionType){
        $this.Device = $Device

        if(-not (Test-Path $MountPath)){
            [System.IO.Directory]::CreateDirectory($MountPath)
        }

        $this.MountPath = $MountPath
        $this.PartitionType = $PartitionType
    }

    PartitionAccessPath([DeviceCollector]$Device,$MountPath){
        $this.Device = $Device

        if(-not (Test-Path $MountPath)){
            [System.IO.Directory]::CreateDirectory($MountPath)
        }
        
        $this.MountPath = $MountPath
    }

    mount(){
        $Partition = $this.Device.get_partitionByType(($this.PartitionType))
        $DiskNumber= $Partition.DiskNumber
        $PartitionNumber = $Partition.PartitionNumber
        Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $this.MountPath -PassThru -ErrorAction 0
    }

    unmount(){
        $Partition = $this.Device.get_partitionByType(($this.PartitionType))
        $DiskNumber= $Partition.DiskNumber
        $PartitionNumber = $Partition.PartitionNumber
        Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $this.MountPath -PassThru | Out-Null
    }

}

#endregion

####################################################
# DataWriter
####################################################
#region DataWriter
class DataWriter{
    write_data(){}
}

class ISO2DiskWriter:DataWriter {

    $SourceDriveLetter
    $TargetDriveLetter

    ISO2DiskWriter($SourceDriveLetter, $TargetDriveLetter){
        $this.SourceDriveLetter = $SourceDriveLetter
        $this.TargetDriveLetter = $TargetDriveLetter
    }

    write_data($LogFile){
        $job = Get-Job -Name ImageCopy -ErrorAction 0
        if($job){$job |Remove-Job}

        Start-Job -ScriptBlock {
            param($SourceDriveLetter, $LogFile, $TargetDriveLetter)
            Robocopy.exe $("{0}:\" -f $SourceDriveLetter) $("{0}:\" -f $TargetDriveLetter) /S /E /MIR /W:1 /R:2 /NP /LOG:$LogFile
        } -ArgumentList $this.SourceDriveLetter, $LogFile, $this.TargetDriveLetter -Name ImageCopy
    }
}

class EFIFile2PartitionWriter:DataWriter {

    # "\EFI\Boot" 'Location of the BCD Store'
    # "EFI\Microsoft\Boot" 'EFIFile destinationpath'

    $FilePath
    $Destination

    EFIFile2PartitionWriter($FilePath,$Destination){
        $this.FilePath = $FilePath
        $this.Destination = $Destination
    }

    write_data(){
        [System.IO.Directory]::CreateDirectory($this.Destination)
        Copy-Item -Path $this.FilePath -Destination $this.Destination -Force
    }

    delete_partition(){
        Remove-Item -Force -Path $this.Destination -Verbose -Confirm:$false -Recurse
    }
}

class Store2PartitionWriter:DataWriter {

    # "\EFI\Boot" 'Location of the BCD Store'
    # "EFI\Microsoft\Boot" 'EFIFile destinationpath'

    $FilePath
    $Destination

    Store2PartitionWriter($FilePath,$Destination){
        $this.FilePath = $FilePath
        $this.Destination = $Destination
    }

    write_data(){
        [System.IO.Directory]::CreateDirectory($this.Destination)
        Copy-Item -Path $this.FilePath -Destination $this.Destination
    }
}
#endregion

