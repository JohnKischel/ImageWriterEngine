
function Get-IWDevice {
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
        $Secure,

        # select this switch to list all drives with driveletter.
        [Parameter(ParameterSetName = "ListAll")]
        [switch]
        $ListAll
    )
    
    begin {

    }
    
    process {
        
        switch ($PSCmdlet.ParameterSetName) {

            #Gets the volume with specific driveletter.
            "GetByDriveLetter" {

                if (-not (Test-Path -Path $("{0}:\" -f $DriveLetter))) {
                    throw ("{0}:\ was not found as path." -f $DriveLetter)
                }  

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

            # List all volumes and disks.
            "ListAll" {
                Get-Volume | Where-Object { $_.DriveLetter } | Format-Table @{Label="DriveLetter";Expression={$_.DriveLetter}},@{Label="FriendlyName";Expression={$_.FileSystemLabel}},@{Label="Size";Expression={$_.Size}}
                Get-Disk | Format-Table @{Label="DiskNumber";Expression={$_.DiskNumber}},@{Label="FriendlyName";Expression={$_.FriendlyName}}
            }
        }
    }
    end { 
        Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DriveLetter' -Value $DriveLetter
        Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DeviceInputObject' -Value $InputObject
    }
}
