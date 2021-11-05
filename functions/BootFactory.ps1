class Store {

    $Path

    Store($Path){
        $this.Path = $Path
    }

    create(){
        bcdedit /createstore $this.Path
    }

    [object] get_bootConfigurtationData(){
        return bcdedit /store $this.Path /enum all /v
    }

    copy_to($Destination){
        Copy-Item -Path $this.Path -Destination $Destination -Force
    }

    move_to($Destination){
        Move-Item -Path $this.Path -Destination $Destination -Force
    }
}

class Entry {

    $BCD
    $id
    $description

    create(){}
}

class BootManager:Entry {
    
    $BCD
    $id = '{bootmgr}'
    $description = "Microsoft Boot Manager"

    BootManager([Store]$BCD,$id,$description){
        $this.BCD = $BCD
        $this.id = $id
        $this.description = $description
    }
    
    create(){
        bcdedit /store $this.BCD.Path /create $this.id /d $this.description
        bcdedit /store $this.BCD.Path /set $this.id description $this.description
        bcdedit /store $this.BCD.Path /set $this.id flightsigning Yes
        #bcdedit /store "$Path" /set '{bootmgr}' displayorder $match | Out-Null
    }

    set_default($Identifier){
        bcdedit /store $this.BCD.Path /set $this.id default "{$Identifier}"
    }

    set_displayorder($Identifier){
        bcdedit /store $this.BCD.Path /set $this.id displayorder "{$Identifier}"
    }
}

class BootLoader:Entry {

    $id
    $description = "ImageWriterEngine"

    BootLoader([Store]$BCD,$description){
        $this.BCD = $BCD
        $this.description = $description
    }

    create(){
        $guid = bcdedit /store $this.BCD.Path /create /d $this.description /application osloader
        $this.id = [regex]::Matches($guid, "\w{0,8}-\w{0,4}-\w{0,4}-\w{0,4}-\w{0,12}").Value
    }

    set_default(){
        bcdedit /store $this.BCD.Path /set '{bootmgr}' default ($this.get_id_as_string()) | Out-Null
    }

    set_displayorder(){
        bcdedit /store $this.BCD.Path /set '{bootmgr}' displayorder ($this.get_id_as_string()) | Out-Null
    }

    set_device($DriveLetter){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) device "ramdisk=[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
    }

    set_path(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) path \windows\system32\boot\winload.efi | Out-Null
    }

    set_description(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) description  'Litetouch Boot [PE] (x64)' | Out-Null
    }

    set_osdevice($DriveLetter){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) osdevice ramdisk="[$DriveLetter`:]\Deploy\Boot\LiteTouchPE_x64.wim,{ramdiskoptions}" | Out-Null
    }

    set_systemroot(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) systemroot \Windows | Out-Null
    }

    set_bootmenupolicy(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) bootmenupolicy Legacy | Out-Null
    }

    set_detecthal(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) detecthal Yes | Out-Null
    }

    set_winpe(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) winpe Yes | Out-Null
    }

    set_ems(){
        bcdedit /store $this.BCD.Path /set ($this.get_id_as_string()) ems Yes | Out-Null
    }

    [string] get_id_as_string(){
        return '{{{0}}}' -f $this.id
    }
}

class RAMDisk:Entry {

    $id = '{ramdiskoptions}'
    $description = 'ramdiskoption'
    $ramdisksdipath = '\boot\boot.sdi'

    RAMDisk([Store]$BCD){
        $this.BCD = $BCD
    }

    RAMDisk([Store]$BCD,$id,$description,$ramdisksdipath){
        $this.BCD = $BCD
        $this.id = $id
        $this.description = $description
        $this.ramdisksdipath = $ramdisksdipath
    }

    create(){
        bcdedit /store $this.BCD.Path /create $this.id /d $this.description
    }

    set($DriveLetter){
        bcdedit /store $this.BCD.Path /set $this.id ramdisksdidevice partition="$DriveLetter`:"
        bcdedit /store $this.BCD.Path /set $this.id ramdisksdipath $this.ramdisksdipath
    }
}
