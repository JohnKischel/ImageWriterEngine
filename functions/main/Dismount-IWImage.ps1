function Dismount-IWImage {
    # Path to the isoimage wich should be mounted.
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Path of the isofile.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImagePath = (Get-PSFConfigValue ImageWriterEngine.Session.DiskImagePath)
    )

    begin {}

    process {
        do {
            # Cleanup mounted Disks
            $result = Dismount-DiskImage -ImagePath $ImagePath
        }until(!$result)
    }
    end {
        #Write-PSFMessage -Level Host -Message "Disk unmounted."
    }
}