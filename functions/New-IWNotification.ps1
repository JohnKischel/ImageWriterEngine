function New-IWNotification {
    [CmdletBinding()]
    param (

        # Message title
        [Parameter()]
        [string]
        $Title = "ImageWriterEngine",

        # Message body
        [Parameter()]
        [String]
        $Message

    )
    Add-Type -AssemblyName System.Windows.Forms
    $global:notify = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -Id $pid).Path
    $notify.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $notify.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $notify.BalloonTipText = $Message
    $notify.BalloonTipTitle = $Title
    $notify.Visible = $true
    $notify.ShowBalloonTip(20000) 
}