function Get-IWProgress {
    param(
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)
    )

    begin { }

    process {
        $Size = (Get-Volume $DriveLetter) | Select-Object Size, SizeRemaining
        $Output = ($Size.Size - $Size.SizeRemaining) / 1GB
        if ($Output -ne $Lastoutput) {
            $Lastoutput = $Output
        }
    }
    
    end {
        Write-Host  ("{0} / {1}" -f $Output, ( ($Size.Size - 1GB )/1GB) )
        Start-Sleep -Seconds 10
    }
}