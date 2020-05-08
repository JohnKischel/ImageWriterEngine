function Mount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [AllowNull()]
        [string]
        $ImagePath = (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
    )

    begin {
        if([String]::IsNullOrEmpty($ImagePath)) {
            Write-PSFMessage -Level Host -Message "Searching for image locally."
            $ImagePath = (Get-ChildItem -Path (Join-PSFPath (Get-PSFConfigValue ImageWriterEngine.Session.Path) -Child "*.iso") -ErrorAction 0).FullName
            if($ImagePath){
                Write-PSFMessage -Level Host -Message ("Image: {0} found." -f $ImagePath)
            }
        }

        if (-not ($ImagePath -match ".+\.iso") -or -not (Test-Path -Path $ImagePath)) {
            throw ("Path doesnt match '.+\.iso' or is not available.")
        }
    }
    process {
        try {
            $InputObject = Get-DiskImage $ImagePath -ErrorAction Stop | Mount-DiskImage -StorageType ISO | Get-Volume
        }
        catch {
            throw "The file or directory is corrupted and unreadable."
        }
        #       
        if ($InputObject) {
            Write-PSFMessage -Level Host -Message ("Image: [ {0} ] mounted as [ {1}: ] with size [ {2:f2} ]" -f $InputObject.FileSystemLabel , $InputObject.DriveLetter, ($InputObject.Size / 1GB ))       
        }
        else {
            throw ("Could not mount Image: {0} the returning Object was null" -f $ImagePath )       
        }
        
        Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImage -Value $InputObject -Description "Mounted Image as object."
        Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImagePath -Value $ImagePath -Description "The path of the iso image."

        if ([System.IO.File]::Exists(("{0}:\Deploy\Boot\LiteTouchPE_x64.wim" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Session.DiskImage).DriveLetter))) {
            Write-PSFMessage -Level Host -Message ("WinPE detected.")       
        }
        else {
            throw [Exception]::new("ISO is not a WINPE.")
        }
    }
    end { 
        return $InputObject
    }

    
}