# ImageWriterEngine
### Make your usbdevice bootable from powershell.

The **ImageWriterEngine** enables you to make your usbdevice bootable with your selected **WinPE-ISO** from the commandline.

# Where to download?

Download the latest release
- > https://github.com/JohnKischel/ImageWriterEngine/releases

    or use 

- > ```git clone https://github.com/JohnKischel/ImageWriterEngine.git --recurse-submodules```

# How to install.

If you **downloaded** the **release** there are two possible solution to install/use the module. First **unzip** the release. Then follow **one** of the solutions.

Solution 1
=====
After you downloaded the module, place the **expanded** zip in a valid **psmodulepath** in the [scope](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules?view=powershell-7#module-and-dsc-resource-locations-and-psmodulepath) of your needs.

To determine wich powershell version you are using and where to copy the module.

Open a WindowsPowershell and type **$PSVersionTable** then press **ENTER**
Look for the entry PSVersion.

|Name|Value|
|---------|-------------|
|PSVersion|5.1.18362.752|

```Powershell
# AllUsers (Recommended)
"C:\Program Files\WindowsPowerShell\Modules"

# For version PowerShell 5.1 (CurrentUser)
'C:\Users\USERNAME\Documents\WindowsPowerShell\Modules'

# CurrentUser PowerShell 7 (CurrentUser)
'C:\Users\USERNAME\Documents\PowerShell\Modules'

# System-wide
"C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
```

If you have some troublewhile installing the module. Click the links for further reading.

[Installing a module in Powershell 5.1](https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-5.1>)

[Installing a module in Powershell 7](https://docs.microsoft.com/de-de/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7)

Solution 2
=====
```diff
Note:
! Only for the current shell session.
- After you close the shell session you have to do import the module again
```
Import the module where **"X:\yourPath\"** is the path where the module is stored locally.
```Powershell
Import-Module "X:\yourPath\ImageWriterEngine"
```

## How to use.
---
```diff
Note:
- Administrator rights are required for all following steps..
```
Open a WindowsPowershell as administrator.
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
You can place your iso file directly under the `$env:Programdata\ImageWriterEngine` path.
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
