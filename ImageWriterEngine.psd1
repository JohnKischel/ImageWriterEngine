@{
	# Script module or binary module file associated with this manifest
	RootModule = 'ImageWriterEngine.psm1'
	
	# Version number of this module.
	ModuleVersion = '0.3.2'
	
	# ID used to uniquely identify this module
	GUID = '307f4397-8108-4952-b92c-d117d0918fad'
	
	# Author of this module
	Author = 'johnKischel'
	
	# Company or vendor of this module
	CompanyName = 'johnkischel'
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2020 johnKischel'
	
	# Description of the functionality provided by this module
	Description = 'Write an iso image to usb.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
	)

	NestedModules = @(@{ModuleName=".\lib\psframework\PSFramework\PSFramework.psd1"; ModuleVersion="1.1.59"})
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\ImageWriterEngine.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\ImageWriterEngine.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\ImageWriterEngine.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
	'Start-ImageWriterEngine',
	'Add-IWBootLoader',
	"Compare-IWImage",
	"Get-IWDevices",
	"Mount-IWImage",
	"Set-IWHardwareDetection",
	"Set-IWPartition",
	"Set-IWPartitionType",
	"Start-IWImageTransfer",
	"Start-IWPrepareDevice",
	"Get-IWDevicePartitions",
	"Get-IWProgress"
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}