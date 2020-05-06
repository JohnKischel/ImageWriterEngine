function Get-IWDevicePartitions {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)

    )
    $Disknumber = (Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk).Number
    $PartitionList = Get-Partition -DiskNumber $Disknumber

    $DeviceData = New-Object PSCustomObject -Property @{
        Disknumber = $Disknumber
        EFIPartitionNumber = ($PartitionList | Where-Object {$_.Type -eq "System"}).PartitionNumber
        BasicPartitionNumber = ($PartitionList | Where-Object {$_.Type -eq "Basic"}).PartitionNumber
    }

    if($PartitionList.Type.Contains("Basic") -and $PartitionList.Type.Contains("Reserved") -and $PartitionList.Type.Contains("System"))
    {
        Set-PSFConfig -Name ImageWriterEngine.Session.Device -Value $DeviceData
        return $true
    }
    return $false
}