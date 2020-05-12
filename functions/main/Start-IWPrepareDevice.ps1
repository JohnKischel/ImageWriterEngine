function Start-IWPrepareDevice
{
    param(
        # This InputObject should be passed from Get-IWDevice
        [Parameter(ValueFromPipeline)]
        $InputObject = (Get-PSFConfigValue ImageWriterEngine.Session.DeviceInputObject),

        # This parameter represents the final DriveLetter after installing the Image.
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [ValidatePattern('[A-Za-z]')]
        [Char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)
    )
    
    begin
    {
        if([String]::IsNullOrWhiteSpace($DriveLetter) -or (Test-Path -Path $DriveLetter))
        {
            $DriveLetter = $((69..90 | ForEach-Object { if ( -not $(Test-Path $("{0}:" -f $([char]$_)))) { [char]$_ } })[0]).toString()
            Set-PSFConfig ImageWriterEngine.Session.DriveLetter -Value $DriveLetter
        }
    }

    process
    {
        $InputObject | Set-IWPartitionType
        $InputObject | Set-IWPartition -WindowsPartition -DriveLetter $DriveLetter -Size ([uint64]((Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).Size) + 1GB)
        $InputObject | Set-IWPartition -MSRPartition
        $InputObject | Set-IWPartition -EfiPartition
    }

    end 
    {
        Get-IWDevicePartitions -DriveLetter $DriveLetter | Out-Null
    }
}