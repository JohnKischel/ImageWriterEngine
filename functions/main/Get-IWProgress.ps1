function Get-IWProgress {
    param(
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)
    )

    begin { }

    process {
        [long]$ImageSize = Get-Volume -DriveLetter (Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).DriveLetter | Select-Object -ExpandProperty Size
        $SizeRemaining = Get-Volume -DriveLetter $DriveLetter | Select-Object -ExpandProperty SizeRemaining
        $Size = Get-Volume -DriveLetter $DriveLetter | Select-Object -ExpandProperty Size

        [long]$UsedSized = $Size - $SizeRemaining
        $PercentageComplete = ($UsedSized / $ImageSize * 100)
        Write-Progress -Activity "ImageCopy" -PercentComplete $PercentageComplete -Status $PercentageComplete
        Start-Sleep -Milliseconds 1500
    }
    
    end { }
}