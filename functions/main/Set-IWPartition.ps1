function Set-IWPartition {
    param(
        # Input Object should be passed from Get-IWDevice
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = "Input Object requires a type of MSFT_Disk")]
        $InputObject,

        # Switch to create a Partition with predefined guid {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}
        [Parameter(ParameterSetName = "WindowsPartition")]
        [Switch]$WindowsPartition,

        # DriveLetter that will be assigned to the WindowsPartition.
        [Parameter(ParameterSetName = "WindowsPartition")]
        [ValidatePattern('[A-Za-z]')]
        [Char]$DriveLetter,

        # DriveLetter that will be assigned to the WindowsPartition.
        [Parameter(ParameterSetName = "WindowsPartition")]
        [uint64]$Size = 45GB,

        # Sets the label of the device
        [Parameter(ParameterSetName = "WindowsPartition")]
        [ValidateLength(1, 15)]
        [string]$LabelName,

        # Switch to create a Partition with predefined guid {e3c9e316-0b5c-4db8-817d-f92df00215ae}
        [Parameter(ParameterSetName = "MSRPartition")]
        [Switch]$MSRPartition,

        # Switch to create a Partition with predefined guid {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}
        [Parameter(ParameterSetName = "EfiPartition")]
        [Switch]$EfiPartition
    )

    begin {

    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            WindowsPartition {

                New-Partition -InputObject $InputObject -GptType $Script:IWConfig.partitiontype.windows -DriveLetter $DriveLetter -Size $Size -ErrorVariable Err -ErrorAction Stop | Out-Null
                if ($Err[0]) {
                    throw 'Could not create a new basic partition.'                  
                }

                # Add log "Set WindowsPartition with GUID {0} on [ {1} - Serialnumber: {2} ]" 
                Format-Volume -FileSystem 'NTFS' -NewFileSystemLabel $LabelName -DriveLetter $DriveLetter  -Force | Out-Null
                # Add log "Formatted Partition to [ NTFS ] and Label [ IWE ]" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Partition.MSR)) -Tag 'Partition'                Set-PSFConfig ImageWriterEngine.Session.DriveLetter -Value $DriveLetter
                break
            }
    
            MSRPartition {
                try {
                    New-Partition -InputObject $InputObject -Size 128MB -GptType $Script:IWConfig.partitiontype.msr -IsActive:$false -IsHidden -ErrorAction Stop | Out-Null
                    # Add log "Set MSRPartition with GUID {0} on [ {1} - Serialnumber: {2} ]"
                } catch {
                    throw 'Could not create the MSR partition.'
                }
                break
            }
    
            EfiPartition {

                New-Partition -InputObject $InputObject -Size 100MB -GptType $Script:IWConfig.partitiontype.efi -IsActive:$false -IsHidden -ErrorAction Stop |`
                    Format-Volume -FileSystem 'FAT32' -NewFileSystemLabel 'System' -Confirm:$false -ErrorAction Stop | Out-Null
                # Add log "Set EFIPartition with GUID {0} on [ {1} - Serialnumber: {2} ]"
                # Add log "Formatted Partition to [ FAT32 ] and Label [ System ]"
                break
            }
        }
    }
   
    end {
    }
}