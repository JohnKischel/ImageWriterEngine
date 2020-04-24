function Set-IWHardwareDetection
{
    param(
        [Parameter(ParameterSetName="StartService")]
        [switch]$Start,

        [Parameter(ParameterSetName="StopService")]
        [switch]$Stop
    )
    $Service = Get-Service -Name "ShellHWDetection"
    if($Start.IsPresent){
        $message = $Service | Start-Service -PassThru
        Write-PSFMessage -Level Host -Message $("Service {0}" -f $message.Status)
    }
    if($Stop.IsPresent){
        $message = $Service | Stop-Service -PassThru
        Write-PSFMessage -Level Host -Message $("Service {0}" -f $message.Status)
    }
}