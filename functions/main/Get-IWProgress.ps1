function Get-IWProgress {
    param(
        [Parameter()]
        $DriveLetter
    )

    begin {
        
        if([string]::IsNullOrEmpty($DriveLetter)){throw "DriveLetter was empty."}
        
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
        Write-Host ("Transfer image: [ ") -NoNewline
        Write-Host ("{0:f2}" -f $Output) -ForegroundColor Yellow -NoNewline
        Write-Host (" \ " -f $Output) -ForegroundColor White -NoNewline
        Write-Host ("{0:f2}" -f (($Size.Size - 1Gb)/1GB)) -ForegroundColor Green -NoNewline
        Write-Host (" ]" -f $Output) -ForegroundColor White -NoNewline
        $Host.UI.RawUI.CursorPosition = @{ X = $x; Y = $y}
        Start-Sleep -Seconds 5
    }
}