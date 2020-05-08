function Start-IWImageTransfer
{
    param
    (
        # Path to the image that´ll be downloaded.
        [Parameter(Mandatory)]
        [string]$ImagePath,

        # Path where the image will be stored.
        [Parameter()]
        [string]$Destination = (Resolve-PSFPath tmp -NewChild)
    )

    begin
    { 
        try
        {
            if ( -not (Test-Path -Path $Destination)) { [System.IO.Directory]::CreateDirectory($Destination) | Out-Null }
            Write-PSFMessage -Level Host -Message ("Destination store created and selected: {0}" -f $Destination)
        }
        catch
        {
            Write-PSFMessage -Level Host -Message ("Could not create {0}" -f $Destination)
        }
    }

    process
    {
        Start-BitsTransfer -Source $ImagePath -Destination $Destination -RetryTimeout 60 -RetryInterval 60 -Asynchronous -DisplayName "WinIso" -TransferType Download

        do
        {
            Write-PSFMessage -Level Host -Message $("TransferJob is in state {0}." -f $(Get-BitsTransfer).JobState)
            Start-Sleep -Seconds 30
        } until ($(Get-BitsTransfer).JobState -eq "Transferred")   
    }

    end
    {
        try
        {
            Get-BitsTransfer -Name WinIso -ErrorAction 0 | Complete-BitsTransfer
            Write-PSFMessage -Level Host -Message ("BITStransfer completed.")    
        }
        catch
        {
            Write-PSFMessage -Level Host -Message ("Could not completed Transfer.")      
        }

        try
        {
            Get-BitsTransfer | Remove-BitsTransfer
            Write-PSFMessage -Level Host -Message ("Jobs cleaned.")
        }
        catch
        {
            Write-PSFMessage -Level Host -Message ("Could not clean Jobs.")          
        }
    }
}