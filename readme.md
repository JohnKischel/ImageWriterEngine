# ImageWriterEngine
### Make your usbdevice bootable from powershell.

The **ImageWriterEngine** enables you to make your usbdevice bootable with your selected **WinPE-ISO** from the commandline.

# Where to download? How to Install

## Download
```git clone https://github.com/JohnKischel/ImageWriterEngine.git```

## Install
After cloning the repository. Copy the whole ImageWriterEngine Folder to one of powershells module pathes.

You can get a list of valid pathes with:
```powershell
$ENV:PSModulePath
```
Extended information needed? [About_PSModulePath](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-5.1)
## How to use.
---
```diff
Note:
- Administrator privileges are required for all following steps.
```
Click Start, type PowerShell, right-click Windows PowerShell, and then click Run as administrator.

Extended information needed? [About_PSModulePath](
https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/starting-windows-powershell?view=powershell-5.1)

---

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

# Troubleshoot

If you have problems a good idea to implement contact me at johnkischel@gmail.com or on github.