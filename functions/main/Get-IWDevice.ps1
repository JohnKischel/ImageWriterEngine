
function Get-IWDevice {
    param(
        # Device DriveLetter
        [Parameter(ParameterSetName = "ByDriveLetter")]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLetter,

        # Use this switch to ignore everything except Removeable devices.
        [Parameter(ParameterSetName = "ByDriveLetter")]
        [switch]
        $Secure,

        # Get devices by using the disknumber.
        [Parameter(ParameterSetName = "ByDiskNumber")]
        [int]
        $DiskNumber,

        # select this switch to list all drives with driveletter.
        [Parameter(ParameterSetName = "ListAll")]
        [switch]
        $ListAll,

        # select this switch to list all drives with driveletter.
        [Parameter(ParameterSetName = "NextDriveLetter")]
        [switch]
        $NextDriveLetter
    )
    
    begin {
        if (-not $NextDriveLetter.IsPresent) {
            $DriveLetter = Test-DriveLetter -DriveLetter $DriveLetter
        }
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {

            #Gets the volume with specific driveletter.
            "ByDriveLetter" {

                if (-not (Test-Path -Path $("{0}:\" -f $DriveLetter))) {
                    throw ("{0}:\ was not found as path." -f $DriveLetter)
                }  

                if ($Secure.IsPresent) {
                    $InputObject = Get-Volume | Where-Object { $_.DriveLetter -eq $DriveLetter -and $_.DriveType -eq "Removable" } | Get-Partition | Get-Disk
                    if (-not $InputObject) {
                        throw 'Object returned was null'
                    }
                } else {
                    $InputObject = Get-Volume -DriveLetter $DriveLetter | Get-Partition | Get-Disk
                    if (-not $InputObject) {
                        throw 'Object returned was null'
                    }
                }
            }

            # Get the disk by disknumber.
            "ByDiskNumber" {
                $InputObject = Get-Disk -Number $DiskNumber -ErrorAction 0
                if (-not $InputObject) {
                    throw 'Object returned was null'
                }
            }

            # List all volumes and disks.
            "ListAll" {
                Get-Volume | Where-Object { $_.DriveLetter } | Format-Table @{Label = "DriveLetter"; Expression = { $_.DriveLetter } }, @{Label = "FriendlyName"; Expression = { $_.FileSystemLabel } }, @{Label = "Size"; Expression = { $_.Size } }
                Get-Disk | Format-Table @{Label = "DiskNumber"; Expression = { $_.DiskNumber } }, @{Label = "FriendlyName"; Expression = { $_.FriendlyName } }
            }

            # Next free volume letter
            "NextDriveLetter" {
                return Get-WmiObject win32_logicaldisk | Select-Object -ExpandProperty DeviceID -Last 1 | ForEach-Object { [char]([int][char]$_[0] + 1) }
            }

        }
    }

    end {
        return @($DriveLetter, $InputObject)
    }
}
