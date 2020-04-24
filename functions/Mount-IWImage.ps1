function Mount-IWImage
{
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ImagePath
    )
    try
    {
        $InputObject = Get-DiskImage $ImagePath | Mount-DiskImage -StorageType ISO | Get-Volume
        Write-PSFMessage -Level Host -Message ("Image: [ {0} ] mounted as [ {1}: ] with size [ {2:f2} ]" -f $InputObject.FileSystemLabel , $InputObject.DriveLetter, ($InputObject.Size / 1GB ))       
    }
    catch
    {
        Write-PSFMessage -Level Host -Message ("Could not mount Image: {0}" -f $ImagePath)       
    }

    return $InputObject
}