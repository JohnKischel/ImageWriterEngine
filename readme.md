# ImageWriterEngine
### Make your usbdevice bootable from powershell.

The **ImageWriterEngine** enables you to make your usbdevice bootable with your selected **WinPE-ISO** from the commandline.

## How to install.
---

Download the latest release
- > https://github.com/JohnKischel/ImageWriterEngine/releases

    or use 

- > ```git clone https://github.com/JohnKischel/ImageWriterEngine.git --recurse-submodules```
---

```diff
Note:
- Administrator rights are required for all following steps..
```

If you downloaded the release there are two possible solution to install/use the module. First **Unzip** the release. Then follow one of the solutions.

Solution 1
=====
After you downloaded the module, place it in a valid **psmodulepath** in the scope of your needs. If you need some help, how to install a module.

[Installing a module in Powershell 5.1](https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-5.1>)

[Installing a module in Powershell 7](https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7)

Solution 2
=====
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
## ISO selection alternative
You can place your iso file directly under the `$env:Programdata` path.
ImageWriterEngine will check for this path.
```diff
Note:
- Only one iso is supported at this time.
```
with this setup you can now use.
```Powershell
Start-ImageWriterEngine -DriveLetter 'YOURdriveletter'

# or 

Start-ImageWriterEngine -DriveLetter 'YOURdriveletter' -Verbose
```
