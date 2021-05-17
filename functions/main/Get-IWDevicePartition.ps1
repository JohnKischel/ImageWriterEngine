function Get-IWDevicePartitions {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)

    )

    begin {      
        if (-not (Test-Path -Path $("{0}:\" -f $DriveLetter))) {
            throw ("{0}:\ was not found as path." -f $DriveLetter)
        }

        $Disknumber = (Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk).Number
        $PartitionList = Get-Partition -DiskNumber $Disknumber
    }

    process {
        $DeviceData = New-Object PSCustomObject -Property @{
            Disknumber           = $Disknumber
            EFIPartitionNumber   = ($PartitionList | Where-Object { $_.Type -eq "System" }).PartitionNumber
            BasicPartitionNumber = ($PartitionList | Where-Object { $_.Type -eq "Basic" }).PartitionNumber
        }
        
        if(($DeviceData.BasicPartitionNumber).Count -ne 1)
        {
            Write-Warning -Message "Attention you are forced to delete your device. Please read the following steps carefully. "
            Start-Job -ScriptBlock{Reset-IWDevice} | Wait-Job
            exit
        }

        if ($DeviceData.Disknumber -and $DeviceData.EFIPartitionNumber -and $DeviceData.BasicPartitionNumber) {
            if ($PartitionList.Type.Contains("Basic") -and $PartitionList.Type.Contains("Reserved") -and $PartitionList.Type.Contains("System")) {
                Set-PSFConfig -Name ImageWriterEngine.Session.DevicePartition -Value $DeviceData
                return $DeviceData
            }
            else {
                throw 'Missing required partition.'
            }
        }
        return $null
    }

    end { }
}