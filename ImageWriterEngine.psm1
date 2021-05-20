#Requires -RunAsAdministrator
$script:ModuleRoot = $PSScriptRoot
$script:ModuleVersion = (Import-PowerShellDataFile -Path "$($script:ModuleRoot)\ImageWriterEngine.psd1").ModuleVersion

function Import-ModuleFile {
	param (
		$File
	)

	Import-Module $File	-Verbose
}

foreach ($file in Get-ChildItem -File "$script:ModuleRoot/functions/" -Recurse) {
	. $file.FullName
}
