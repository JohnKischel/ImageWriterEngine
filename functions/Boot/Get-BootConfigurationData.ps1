function Get-IWBootConfigurationData {
    [CmdletBinding()]
    param (
        [Parameter()]
        [char]
        [ValidatePattern('[A-Za-z]')]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter),

        [Parameter()]
        [string]
        $StorePath = (Get-PSFConfigValue ImageWriterEngine.Session.StorePath)

    )
    
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }
    
    # Returns all entries in the given store.
    process {
        return bcdedit /store ("{0}\BCD" -f $StorePath) /enum all /v
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}