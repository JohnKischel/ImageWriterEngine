function Copy-IWImage {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DriveLetter,

        [Parameter()]
        $ImageDriveLetter,

        [Parameter()]
        $LogFile
    )

    begin{
        $DriveLetter = Test-DriveLetter -DriveLetter $DriveLetter
        $ImageDriveLetter = Test-DriveLetter -DriveLetter $ImageDriveLetter

        if(-not (Test-Path $LogFile)){throw "LogFile not valid."}
    }

    process {
        if ($PSEdition -eq "Core") {
            Start-ThreadJob -ScriptBlock {
                param($ImageDriveLetter, $LogFile, $DriveLetter)
                Robocopy.exe $("{0}:\" -f $ImageDriveLetter) $("{0}:\" -f $DriveLetter) /S /E /MIR /W:1 /R:2 /NP /LOG:$LogFile
            } -ArgumentList $ImageDriveLetter, $LogFile, $DriveLetter -Name ImageCopy
        }else{
            Start-Job -ScriptBlock {
                param($ImageDriveLetter, $LogFile, $DriveLetter)
                Robocopy.exe $("{0}:\" -f $ImageDriveLetter) $("{0}:\" -f $DriveLetter) /S /E /MIR /W:1 /R:2 /NP /LOG:$logfile
            } -ArgumentList $ImageDriveLetter, $LogFile, $DriveLetter -Name ImageCopy
        }

        if ($job = Get-Job -Name ImageCopy) {
            $job
            # Add log "Job {0} started with ID {1}"
        }
    }

    end { }
}