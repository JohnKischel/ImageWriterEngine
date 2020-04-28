#Requires -RunAsAdministrator
Copy-Item -Path "..\ImageWriterEngine" $env:programfiles\WindowsPowershell\Modules -Recurse -Exclude "install.ps1","lib\" -Force
Copy-Item -Path "..\ImageWriterEngine\lib\psframework\PSFramework" $env:programfiles\WindowsPowershell\Modules -Recurse -Force
