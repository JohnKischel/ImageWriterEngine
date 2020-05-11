function Get-IWProgress {
    param(
        [Parameter()]
        [ValidatePattern('[A-Za-z]')]
        [char]
        $DriveLetter = (Get-PSFConfigValue ImageWriterEngine.Session.DriveLetter)
    )

    begin { 
        $x = [Console]::CursorLeft
        $y = [Console]::CursorTop
    }

    process {
        $Size = (Get-Volume $DriveLetter) | Select-Object Size, SizeRemaining
        $Output = ($Size.Size - $Size.SizeRemaining) / 1GB
        if ($Output -ne $Lastoutput) {
            $Lastoutput = $Output
        }

    }
    
    end {
        Write-Host  ("Transfer image: [ {0} / {1} ]" -f $Output, ( ($Size.Size)/1GB) ) -ForegroundColor Green
        $Host.UI.RawUI.CursorPosition = @{ X = $x; Y = $y }

        Start-Sleep -Seconds 5
    }
}