@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'ImageWriterEngine.psm1'
	
	# Version number of this module.
	ModuleVersion     = '0.8.0'
	
	# ID used to uniquely identify this module
	GUID              = '307f4397-8108-4952-b92c-d117d0918fad'
	
	# Author of this module
	Author            = 'johnKischel'
	
	# Company or vendor of this module
	CompanyName       = 'johnkischel'
	
	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2021 johnKischel'
	
	# Description of the functionality provided by this module
	Description       = 'Write an iso image to usb.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Nested modules
	NestedModules     = @(
	)

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\ImageWriterEngine.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\ImageWriterEngine.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\ImageWriterEngine.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		"Set-IWHardwareDetection",
		'Start-ImageWriterEngine',
		'New-IWNotification'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport   = @(
	
	)
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport   = ''
	
	# List of all modules packaged with this module
	ModuleList        = @()
	
	# List of all files packaged with this module
	FileList          = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{
		
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