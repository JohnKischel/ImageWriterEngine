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
            # Add log "Destination store created and selected: {0}" -f $Destination
        }
        catch
        {
            # Add log "Could not create {0}" -f $Destination
        }
    }

    process
    {
        Start-BitsTransfer -Source $ImagePath -Destination $Destination -RetryTimeout 60 -RetryInterval 60 -Asynchronous -DisplayName "WinIso" -TransferType Download

        do
        {
            # Add log ("TransferJob is in state {0}." -f $(Get-BitsTransfer).JobState
            Start-Sleep -Seconds 30
        } until ($(Get-BitsTransfer).JobState -eq "Transferred")   
    }

    end
    {
        try
        {
            Get-BitsTransfer -Name WinIso -ErrorAction 0 | Complete-BitsTransfer
            # Add log "BITStransfer completed."    
        }
        catch
        {
            # Add log "Could not completed Transfer."      
        }

        try
        {
            Get-BitsTransfer | Remove-BitsTransfer
            # Add log "Jobs cleaned."
        }
        catch
        {
            # Add log "Could not clean Jobs."          
        }
    }
}