function New-IWBootManager {

    param(
        # Location of the BootManager store
        [Parameter()]
        [string]
        $StorePath = "$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)\BCD"
    )
    # DriveLetter?
    
    if (-not ([System.IO.File]::Exists($StorePath))) {
        [System.IO.Directory]::CreateDirectory("$(Get-PSFConfigValue ImageWriterEngine.Session.EFIPath)") | Out-Null
        [System.IO.Directory]::CreateDirectory("$(Get-PSFConfigValue ImageWriterEngine.Session.StorePath)") | Out-Null
    }

    bcdedit.exe /createstore $StorePath | Out-Null
    Write-PSFMessage -Level Host -Message $StorePath -Tag "Bootloader" 
    bcdedit.exe /store $StorePath /create '{bootmgr}' /d "Microsoft Boot Manager" | Out-Null
    Write-PSFMessage -Level Host -Message ("Create Microsoft Boot Manager.") -Tag "Bootloader"

    bcdedit /store $StorePath /set '{bootmgr}' description 'Windows Boot Manager' | Out-Null
    bcdedit /store $StorePath /set '{bootmgr}' flightsigning Yes | Out-Null
    bcdedit /store $StorePath /set '{bootmgr}' displayorder $match | Out-Null
}