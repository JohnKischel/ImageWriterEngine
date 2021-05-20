function Test-DriveLetter() {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DriveLetter
    )

    try {
        $DriveLetter = $DriveLetter.ToString()
        $DriveLetter = $DriveLetter.toLower()
    } catch {
        throw "Could not prepare object."
    }

    $DriveLetter = [regex]::Matches($DriveLetter, '^[a-zA-Z]').value
    if (-not ($DriveLetter -match '[a-zA-Z]')) {
        throw "Driveletter does not look like a valid volume letter."
    }

    return $DriveLetter
}

function ValidatePath {
    [CmdletBinding()]
    param (
        $Path
    )

    if ([System.IO.Path]::IsPathRooted($Path) -and [System.IO.Path]::HasExtension($Path)) {

        if (-not (Test-Path $Path)) {
            throw "Path [ $Path ] not found or not valid"
        }

    } else {

        if (-not ([System.IO.Path]::HasExtension($Path))) {
            throw "Path needs an extension like .iso order .img"
        }

        $Path = (Get-ChildItem $script:ModuleRoot -Recurse -Filter $Path).Fullname
        
        if ([string]::IsNullOrEmpty($Path)) {
            throw "Could not find path because its null or empty."
        }

        if (-not (Test-Path $Path)) {
            throw "Path [ $Path ] not found or not valid"
        }
        
    }    

    return $true
}

