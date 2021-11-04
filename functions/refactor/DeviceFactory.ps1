####################################################
# DeviceFactory Classes
####################################################

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
        try{
            Clear-Disk -RemoveData -Confirm:$false -InputObject $this.Device.VolumeObject -RemoveOEM -ErrorAction Stop
            $this.isCleared = 0
        }catch{
            throw "Failure while cleaning the disk."
        }
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

####################################################
# DeviceCollector Classes
####################################################

class DeviceCollector{
    [Object] $VolumeObject

    [bool] is_gpt(){
        if($this.VolumeObject.PartitionStyle -eq 'GPT'){
            return $true
        }
        return $false
    }

}

class DeviceCollectorByDriveLetter:DeviceCollector{
    DeviceCollectorByDriveLetter($DriveLetter){
        $this.VolumeObject = Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk
    }

    [object] get_partition(){
        return $this.VolumeObject |Get-Partition
    }
}

class DeviceCollectorByDiskNumber:DeviceCollector{
    DeviceCollectorByDiskNumber($DiskNumber){
        $this.VolumeObject = Get-Disk -Number $DiskNumber -ErrorAction 0
    }

    [object] get_partition(){
        return $this.VolumeObject |Get-Partition
    }
}


####################################################
# Partition Classes
####################################################

class Partition{
    $Size

    create_partition(){}
}

#New-Partition -InputObject $InputObject -Size 128MB -GptType $Script:IWConfig.partitiontype.msr -IsActive:$false -IsHidden -ErrorAction Stop | Out-Null
#New-Partition -InputObject $InputObject -Size 100MB -GptType $Script:IWConfig.partitiontype.efi -IsActive:$false -IsHidden -ErrorAction Stop |`


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


[DeviceCollectorByDriveLetter]::new('E').get_partition()
[DeviceCollectorByDiskNumber]::new(1).get_partition()
$dc = [DeviceCollectorByDiskNumber]::new(1)
$dc.get_partition()

$wp = [WindowsPartition]::new('E',50GB)
$ep = [EfiPartition]::new()
$mp = [MSRPartition]::new()
$parts = $wp,$ep,$mp
$df = [DeviceFactory]::new($dc,$parts)
#$df.clear_device()
#$df.create_partition()
