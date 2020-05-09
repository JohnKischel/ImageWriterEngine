
function Get-IWDevices {
    param(
        # Device DriveLetter
        [Parameter(ParameterSetName = "GetByDriveLetter")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter,

        # Use this switch to ignore everything except Removeable devices.
        [Parameter(ParameterSetName = "GetByDriveLetter")]
        [switch]
        $Secure
    )
    
    begin {
        if (-not (Test-Path -Path $("{0}:\" -f $DriveLetter))) {
            throw ("{0}:\ was not found as path." -f $DriveLetter)
        }  
    }
    
    process { 
        if ($Secure.IsPresent) {
            $InputObject = Get-Volume | Where-Object { $_.DriveLetter -eq $DriveLetter -and $_.DriveType -eq "Removable" } | Get-Partition | Get-Disk
            if ($InputObject) {
                return $InputObject
            }
            else {
                throw 'Object returned was null'
            }
        }
        else {
            $InputObject = Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk
            if ($InputObject) {
                return $InputObject
            }
            else {
                throw 'Object returned was null'
            }
        }
            
    }
    end { 
        Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DriveLetter' -Value $DriveLetter
        Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DeviceInputObject' -Value $InputObject
    }
}
