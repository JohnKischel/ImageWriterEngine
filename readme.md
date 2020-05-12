# ImageWriterEngine
### Make your usbdevice bootable from powershell.

The **ImageWriterEngine** enables you to make your usbdevice bootable with your selected **WinPE-ISO** from the commandline.

## How to install.
---

Download the latest release
- > https://github.com/JohnKischel/ImageWriterEngine/releases

    or use 

- > ```git clone https://github.com/JohnKischel/ImageWriterEngine.git --recurse-submodules```

After you downloaded the module place it in a valid **psmodulepath** in the scope of your favour.

- > https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7
- > https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-5.1


```diff
- Attention

Administrator rights are required.
```
Import the module where **"X:\yourPath\"** is the path where the module is stored.
```Powershell
Import-Module "X:\yourPath\ImageWriterEngine"
```


## How to use.
```Powershell
# Example YOURdriveletter F
# Example YOURisopath E:\MyISOs\MyWinPE.iso

Start-ImageWriterEngine -DriveLetter 'YOURdriveletter' -ImagePath 'YOURisopath'
```

for a more detailed output do **-Verbose**.
```
Start-ImageWriterEngine -DriveLetter 'yourDriveLetter' -ImagePath 'yourISOPath' -Verbose
```