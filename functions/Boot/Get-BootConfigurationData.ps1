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
    
    process {
        return bcdedit /store ("{0}\BCD" -f $StorePath) /enum all /v
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}