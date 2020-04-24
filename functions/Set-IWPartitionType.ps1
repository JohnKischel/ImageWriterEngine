function Set-IWPartitionType
{
    param(
        #Input Object should be parsed from Get-IWDevices
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    begin{}

    process
    {
        try
        {
            Clear-Disk -RemoveData -Confirm:$false -InputObject $InputObject -RemoveOEM
            Write-PSFMessage -Level Host -Message ("Device {0} with serialnumber {1} cleaned." -f $InputObject.FriendlyName, $InputObject.SerialNumber)
        }
        catch
        {
            Write-PSFMessage -Level Host -Message "Failure while cleaning the disk."
        }
        
        try
        {
            Set-Disk -PartitionStyle GPT -InputObject $InputObject
            Write-PSFMessage -Level Host -Message ("Device {0} is now GPT" -f $InputObject.FriendlyName)
        }
        catch
        {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
        }
    }

    end{}
}