function Set-IWHardwareDetection {
    param(
        [Parameter(ParameterSetName = "StartService")]
        [switch]$Start,

        [Parameter(ParameterSetName = "StopService")]
        [switch]$Stop
    )
    
    begin {
        $Service = Get-Service -Name "ShellHWDetection"
    }

    process {
        if ($Start.IsPresent) {
            $message = $Service | Start-Service -PassThru
        }
        if ($Stop.IsPresent) {
            $message = $Service | Stop-Service -PassThru
        }
    }

    end {
        Write-PSFMessage -Level Host -Message $("Service {0}" -f $message.Status) 
    }

}