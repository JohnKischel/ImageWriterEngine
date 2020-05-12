# ImageWriterEngine
## Make your usbdevice Bootable from CLI.

The ImageWriterEngine enables you to make your usbdevice bootable with your selected *WinPE-ISO* from the commandline.

## How to install.
---
- Download the latest release
- Expand the zip archive and store the module in a valid powershellmodule path.
> https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7
> https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-5.1

or use

> ```git clone https://github.com/JohnKischel/ImageWriterEngine.git --recurse-submodules```

## Easy to use.
```
Start-ImageWriterEngine -DriveLetter 'yourDriveLetter' -ImagePath 'yourISOPath'
```
This command will prepare your device with all partitions needed. Copy your image and create the neccesary bootloader/bootmgr.
