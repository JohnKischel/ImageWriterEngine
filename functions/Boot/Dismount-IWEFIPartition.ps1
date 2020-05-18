function Dismount-IWEFIPartition {

    param (
        [Parameter()]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),

        # Path where the EFIpartition should be mounted
        [Parameter()]
        [string]
        $MountPath = (Get-PSFConfigValue ImageWriterEngine.Session.MountPath),

        [Parameter()]
        [string]
        $DiskNumber = (Get-PSFConfigValue ImageWriterEngine.Session.DevicePartition).Disknumber,

        [Parameter()]
        [string]
        $PartitionNumber = (Get-PSFConfigValue ImageWriterEngine.Session.DevicePartition).EFIPartitionNumber
    )
    
    begin { 
    }

    process {
        if((Get-PSFConfigValue ImageWriterEngine.Session.isMounted) -eq 0) {break}
        $PartitionType = (Get-Partition -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber).Type
        if ($PartitionType -ne 'System') {
            throw ("Partition type is {0} bit Type 'System' is expected." -f $PartitionType)
        }

        if (-not(Test-Path -Path $MountPath)) {
            throw 'Path does not exist.'
        }

        if (-not (Remove-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -AccessPath $MountPath -PassThru -ErrorAction 0)) {
            throw 'The access path is not valid or no volume is mounted.'
        }
        else {
            Write-PSFMessage -Level Verbose -Message ("Dismounted EFIPartition.") -Tag 'EFIPartition'
            Set-PSFConfig -FullName ImageWriterEngine.Session.isMounted -Value 0
        }
    }

    end { }
}