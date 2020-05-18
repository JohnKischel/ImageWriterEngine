<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

# custom

# Partition settings
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Partition.Windows' -Value '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}' -Description 'Predefined WindowsPartition GUID.'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Partition.EFI' -Value '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' -Description 'Predefined EFIPartition GUID'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Partition.MSR' -Value '{e3c9e316-0b5c-4db8-817d-f92df00215ae}' -Description 'Predefined MSRPartition GUID.'

# Pathes
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.Path' -Value (Join-PSFPath $env:ProgramData -Child ImageWriterEngine) -Description 'Path of the current ImageWriterSession'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.Id' -Value (New-Guid).Guid -Description 'ImageWriteEngine sessionId'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.CurrentSession' -Value (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Path) -Child (Get-PSFConfigValue -FullName ImageWriterEngine.Session.Id) ) -Description 'ImageWriteEngine sessionId'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.MountPath' -Value (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.CurrentSession) -Child "mnt" ) -Description 'Folder wich mounts the EFIPartition.'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.isMounted' -Value 0 -Description 'Holds a record of the mountpath mounted status.'

# LOGPath
Set-PSFConfig -Module 'PSFramework' -Name 'Logging.FileSystem.LogPath' -Value (Join-PSFPath (Get-PSFConfigValue -FullName ImageWriterEngine.Session.CurrentSession) -Child "Logs")
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.EFIPath' -Value (Join-PSFPath -Path (Get-PSFConfigValue ImageWriterEngine.Session.MountPath) -Child "\EFI\Boot") -Description 'Location of the BCD Store'
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.StorePath' -Value (Join-PSFPath -Path (Get-PSFConfigValue ImageWriterEngine.Session.MountPath) -Child "EFI\Microsoft\Boot") -Description 'EFIFile destinationpath'

Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DiskImage' -Value $null -Description "Full diskobject."
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DiskImagePath' -Value $null -Description "The path of the iso image."

Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DriveLetter' -Value $null -Description "Device driveletter"
Set-PSFConfig -Module 'ImageWriterEngine' -Name 'Session.DeviceInputObject' -Value $null -Description "Device driveletter"