# ImageWriterEngine
## Make your usbdevice Bootable from CLI.

The ImageWriterEngine enables you to make your usbdevice bootable with your selected WinPE-ISO form the commandline.

## How to install.
---
- Download the latest release.
- Expand the zip archive.
- Open an administrative WindowsPowershell.
- change the directory to ImageWriterEngine
```
.\install.ps1
```

## Easy to use.
---
>  Selects the DriveLetter automatically. (Requires only one usbdevice connected)
```
Start-ImageWriterEngine -ImagePath 'yourISOPath'
```

> With specified DriveLetter
```
Start-ImageWriterEngine -DriveLetter 'yourDriveLetter' -ImagePath 'yourISOPath'
```