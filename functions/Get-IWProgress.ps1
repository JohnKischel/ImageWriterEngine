function Get-IWProgress {
    param(
        [Parameter()]
        [char]
        $DriveLetter
    )

    do {
        [long]$ImageSize = Get-Volume -DriveLetter (Get-PSFConfigValue ImageWriterEngine.Session.DiskImage).DriveLetter | Select-Object -ExpandProperty Size

        $SizeRemaining = Get-Volume -DriveLetter $DriveLetter | Select-Object -ExpandProperty SizeRemaining
        $Size = Get-Volume -DriveLetter $DriveLetter | Select-Object -ExpandProperty Size

        [long]$UsedSized = $Size - $SizeRemaining
        $PercentageComplete = ($UsedSized / $ImageSize * 100)
        if($PercentageComplete -ge 100.00){$PercentageComplete = 100}
        Write-Progress -Activity "ImageCopy" -PercentComplete $PercentageComplete -Status $PercentageComplete
        Start-Sleep -Milliseconds 1500

    }while ($PercentageComplete -ne 100)

    Write-Progress -Activity "ImageCopy" -Completed
}