function New-IWBootManager {

    param(
        [Parameter()]
        $Destination
        # Location of the BootManager store
    )

    begin {
    }
    
    # A new BCDstore will be created on the specified device and some presettings are parsed to it.
    process {
        bcdedit /createstore "$Destination" | Out-Null
        
        # Add log  "$Destination"
        bcdedit /store "$Destination" /create '{bootmgr}' /d "Microsoft Boot Manager" | Out-Null

        # Add log  "Create Microsoft Boot Manager."
        bcdedit /store "$Destination" /set '{bootmgr}' description 'Windows Boot Manager' | Out-Null
        bcdedit /store "$Destination" /set '{bootmgr}' flightsigning Yes | Out-Null
        bcdedit /store "$Destination" /set '{bootmgr}' displayorder $match | Out-Null
    }

    end {
    }
}