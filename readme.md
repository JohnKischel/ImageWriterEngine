# ImageWriterEngine
### Make your usbdevice bootable from powershell.

The **ImageWriterEngine** enables you to make your usbdevice bootable with your selected **WinPE-ISO** from the commandline.

# Where to download?

Download the latest release.
- > https://github.com/JohnKischel/ImageWriterEngine/releases
    - For a **simple** installation download the **ImageWriterEngine.exe**
    - For a **specific** installation where a different [module scope](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7#module-and-dsc-resource-locations-and-psmodulepath) is required download the ImageWriterEngine.zip and follow [Installing a module in Powershell 5.1](https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-5.1>) or 
[Installing a module in Powershell 7](https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7)

    or use 

- > ```git clone https://github.com/JohnKischel/ImageWriterEngine.git --recurse-submodules```

## How to use.
---
```diff
Note:
- Administrator privileges are required for all following steps.
```
Open a WindowsPowershell as Administrator.
```Powershell
# Determine your device volume letter and replace <YOURdriveletter> with it.
# Determine <YOURisopath> - for example my iso path is E:\MyISOs\MyWinPE.iso

Start-ImageWriterEngine -DriveLetter <YOURdriveletter> -ImagePath <YOURisopath>

# Example !!! It can look like the following command
Start-ImageWriterEngine -DriveLetter F -ImagePath 'E:\MyISOs\MyWinPE.iso'
```

for a more detailed output do **-Verbose**.
```PowerShell
Start-ImageWriterEngine -DriveLetter 'yourDriveLetter' -ImagePath 'yourISOPath' -Verbose
```
## ISO selection alternative
You can place your iso file directly under the `$env:Programdata\ImageWriterEngine` path.
ImageWriterEngine will check for this path.
```diff
Note:
- Only one iso is supported at this time.
```
with this setup you can now use:
```Powershell
Start-ImageWriterEngine -DriveLetter <YOURdriveletter>

# or 

Start-ImageWriterEngine -DriveLetter <YOURdriveletter> -Verbose
```