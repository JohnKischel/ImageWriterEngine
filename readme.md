# ImageWriterEngine
### Make your usbdevice bootable from powershell.

The **ImageWriterEngine** enables you to make your usbdevice bootable with your selected **WinPE-ISO** from the commandline.

# Where to download?

- > ```git clone https://github.com/JohnKischel/ImageWriterEngine.git```

## How to use.
---
```diff
Note:
- Administrator privileges are required for all following steps.
```
Click Start, type PowerShell, right-click Windows PowerShell, and then click Run as administrator.

There are two steps to pre execute:

1. Determine your device  **VOLUMELETTER** or your device **DISKNUMBER**
2. Determine your iso path for example: **E:\MyISOs\MyWinPE.iso**

> HINT

- You can obtain the disknumber simply by executing: `Get-Disk`

Example Output:

| Number | Friendly | Name | Serial Number | HealthStatus | OperationalStatus | Total Size Partition | Style |
|---|---|---|---|---|---|---|---|
| 0 | Samsung | SSD 840 EVO 250GB |xxxxxxxxxxx|Healthy|Online|232.89 GB|GPT|                                                                                            
| **1** | SanDisk   | Ultra |xxxxxxxxxxx|Healthy|Online|119.43 GB| GPT|   
          
```powershell
# Example by DriveLetter
Start-ImageWriterEngine -DriveLetter <YOURdriveletter> -ImagePath <YOURisopath>

# Example by DriveLetter
Start-ImageWriterEngine -DriveLetter <YOURDiskNumber> -ImagePath <YOURisopath>

# Example with parameters !!! In my case, i choosed the Disknumber (see table the one is bold)
Start-ImageWriterEngine -DiskNumber 1 -ImagePath 'E:\MyISOs\MyWinPE.iso'
```

Press return to start the installaton.
