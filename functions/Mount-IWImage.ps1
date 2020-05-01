function Mount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage="Path of the isofile.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImagePath
    )

    begin {
        if (!($ImagePath -match ".+\.iso") -or !(Test-Path -Path $ImagePath))
        {
            $ImagePath = (Get-ChildItem -Path .\ISO\*.iso -ErrorAction 0).FullName
            if ([String]::IsNullOrEmpty($ImagePath))
            {
                Write-PSFMessage -Level Host -Message "No ISO found."
                exit
            }
        }	
    }
    process {
        try {
            $InputObject = Get-DiskImage $ImagePath | Mount-DiskImage -StorageType ISO | Get-Volume
            Write-PSFMessage -Level Host -Message ("Image: [ {0} ] mounted as [ {1}: ] with size [ {2:f2} ]" -f $InputObject.FileSystemLabel , $InputObject.DriveLetter, ($InputObject.Size / 1GB ))       
        }
        catch {
            Write-PSFMessage -Level Host -Message ("Could not mount Image: {0}" -f $ImagePath)       
        }
    
        Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImage -Value $InputObject -Description "Mounted Image as object."
        Set-PSFConfig -FullName ImageWriterEngine.Session.DiskImagePath -Value $ImagePath -Description "The path of the iso image."

        if([System.IO.File]::Exists(("{0}:\Deploy\Boot\LiteTouchPE_x64.wim" -f (Get-PSFConfigValue -FullName ImageWriterEngine.Session.DiskImage).DriveLetter)))
        {
            Write-PSFMessage -Level Host -Message ("WinPE detected.")       
        }
        else{
            throw [Exception]::new("ISO is not a WINPE.")
        }
    }
    end { 
        return $InputObject
    }

    
}