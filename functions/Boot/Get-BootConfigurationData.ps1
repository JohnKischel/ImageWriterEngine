function Get-IWBootConfigurationData {
    [CmdletBinding()]
    param (
        [Parameter()]
        [char]
        $DriveLetter
    )
    
    begin {
        Mount-IWEFIPartition -DriveLetter $DriveLetter
    }
    
    process {
        return bcdedit.exe /store ("{0}\BCD" -f (Get-PSFConfigValue ImageWriterEngine.Session.StorePath)) /enum all /v
    }
    
    end {
        Dismount-IWEFIPartition -DriveLetter $DriveLetter
    }
}