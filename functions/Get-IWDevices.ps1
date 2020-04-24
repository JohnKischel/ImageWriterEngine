function Get-IWDevices
{
    # TODO: Make a selection enable the user to choose the device.
    try
    {
        $InputObject = Get-Disk | Where-Object { $_.BusType -eq 'USB' }
        return $InputObject
    }
    catch
    {
        Write-PSFMessage -Level Host -Message $_.Exception.Message
    }
}