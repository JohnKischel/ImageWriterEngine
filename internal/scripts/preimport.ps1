# Add all things you want to run before importing the main code

# Load the strings used in messages
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\strings.ps1"
Import-Module "$($script:ModuleRoot)\internal\RequiredModules\PSFramework\PSFramework\PSFramework.psd1" -Verbose