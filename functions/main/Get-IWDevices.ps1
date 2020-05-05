
function Get-IWDevices {
    param(
        # Device DriveLetter
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [char]
        $DriveLetter,

        # Use this switch to ignore not everything except Removeable devices
        [switch]
        $Secure
    )
    begin {
    }
    
    process { 
        
        try {
            if($Secure.IsPresent){
                # 1[System.IO.DriveInfo]::GetDrives() | Where-Object { $_.Name -eq "${DriveLetter}:\" -and $_.DriveType -eq "Removeable" }                
                $InputObject = Get-Volume | Where-Object {$_.DriveLetter -eq $DriveLetter -and $_.DriveType -eq "Removable"} | Get-Partition | Get-Disk
                return $InputObject                
            }
            $InputObject = Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk
            return $InputObject
        }
        catch {
            Write-PSFMessage -Level Host -Message $_.Exception.Message
            exit
        }
    }

    end { }
    
}