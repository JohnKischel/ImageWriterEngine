# Add all things you want to run before importing the main code

# Load the strings used in messages
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope MachinePolicy -Force
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\strings.ps1"