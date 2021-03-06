function Set-IWPartition {
    param(
        #Input Object should be passed from Get-IWDevice
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = "Input Object requires a type of MSFT_Disk")]
        $InputObject,

        #Switch to create a Partition with predefined guid {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}
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
        [ValidateLength(1,10)]
        [string]$LabelName = "IWE",

        #Switch to create a Partition with predefined guid {e3c9e316-0b5c-4db8-817d-f92df00215ae}
        [Parameter(ParameterSetName = "MSRPartition")]
        [Switch]$MSRPartition,

        #Switch to create a Partition with predefined guid {c12a7328-f81f-11d2-ba4b-00a0c93ec93b}
        [Parameter(ParameterSetName = "EfiPartition")]
        [Switch]$EfiPartition
    )

    begin {
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            WindowsPartition {

                New-Partition -InputObject $InputObject -GptType $(Get-PSFConfigValue -FullName ImageWriterEngine.Partition.Windows) -Size $Size -DriveLetter $DriveLetter -ErrorVariable Err -ErrorAction Stop | Out-Null
                if ($Err[0]) {
                    throw 'Could create a new basic partition.'                  
                }

                Write-PSFMessage -Level Verbose -Message ("Set WindowsPartition with GUID {0} on [ {1} - Serialnumber: {2} ]" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Partition.Windows), $InputObject.FriendlyName, $InputObject.SerialNumber) -Tag 'Partition'
                Format-Volume -FileSystem 'NTFS' -NewFileSystemLabel $LabelName -DriveLetter $DriveLetter  -Force | Out-Null
                Write-PSFMessage -Level Verbose -Message ("Formatted Partition to [ NTFS ] and Label [ IWE ]" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Partition.MSR)) -Tag 'Partition'
                Set-PSFConfig ImageWriterEngine.Session.DriveLetter -Value $DriveLetter
                break
            }
    
            MSRPartition {
                try {
                    New-Partition -InputObject $InputObject -Size 128MB -GptType $(Get-PSFConfigValue -FullName ImageWriterEngine.Partition.MSR) -IsActive:$false -IsHidden -ErrorAction Stop | Out-Null
                    Write-PSFMessage -Level Verbose -Message ("Set MSRPartition with GUID {0} on [ {1} - Serialnumber: {2} ]" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Partition.MSR), $InputObject.FriendlyName, $InputObject.SerialNumber)  -Tag 'Partition'
                }
                catch {
                    throw 'Could not create the MSR partition.'
                }
                break
            }
    
            EfiPartition {

                New-Partition -InputObject $InputObject -Size 100MB -GptType $(Get-PSFConfigValue -FullName ImageWriterEngine.Partition.EFI) -IsActive:$false -IsHidden -ErrorAction Stop |`
                    Format-Volume -FileSystem 'FAT32' -NewFileSystemLabel 'System' -Confirm:$false -ErrorAction Stop | Out-Null
                Write-PSFMessage -Level Verbose -Message ("Set EFIPartition with GUID {0} on [ {1} - Serialnumber: {2} ]" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Partition.EFI), $InputObject.FriendlyName, $InputObject.SerialNumber)
                Write-PSFMessage -Level Verbose -Message ("Formatted Partition to [ FAT32 ] and Label [ System ]" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Partition.MSR))
                break
            }
        }
    }
   
    end {
    }
}