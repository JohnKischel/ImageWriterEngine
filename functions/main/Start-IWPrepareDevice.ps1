function Start-IWPrepareDevice
{
    param(
        # This InputObject should be passed from Get-IWDevices
        [Parameter(ValueFromPipeline)]
        $InputObject = (Get-PSFConfigValue ImageWriterEngine.Session.DeviceInputObject),

        # This parameter represents the final DriveLetter after installing the Image.
        [Parameter()]
        [AllowEmptyString()]
        [Char]
        $DriveLetter
    )
    
    begin
    {
        if([String]::IsNullOrWhiteSpace($DriveLetter) -or (Test-Path -Path $DriveLetter) -or $DriveLetter -eq '^')
        {
            $DriveLetter = $((69..90 | ForEach-Object { if ( -not $(Test-Path $("{0}:" -f $([char]$_)))) { [char]$_ } })[0]).toString()
        }
    }

    process
    {
        $InputObject | Set-IWPartitionType
        $InputObject | Set-IWPartition -WindowsPartition -DriveLetter $DriveLetter
        $InputObject | Set-IWPartition -MSRPartition
        $InputObject | Set-IWPartition -EfiPartition
    }

    end 
    {
        return $DriveLetter
    }
}