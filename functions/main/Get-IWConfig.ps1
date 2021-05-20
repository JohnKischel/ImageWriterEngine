function Get-IWConfig {
    # This function loads a yaml structured config file.

    param (
        [Parameter(Position = 0, HelpMessage = "Path to a yaml config file.")]
        [string]
        $ConfigFile = "config.yaml",

        [switch]$SetAsEnvironmentVariable
    )

    # if the ConfigFile variable is empty it will look for a config file in its scriptroot.
    if ([System.IO.Path]::IsPathRooted($ConfigFile)) {
        $pathIsValid = (Test-Path $ConfigFile) 
    } else {
        $ConfigFile = (Get-ChildItem $script:ModuleRoot -Recurse -Filter $ConfigFile).Fullname
        $pathIsValid = (Test-Path $ConfigFile)
    }
   
    if ($pathIsValid) {
        $config = Get-Content -Path $ConfigFile | ConvertFrom-Yaml
    } else {
        throw "Could not find path [$ConfigFile]"
    }

    if ($SetAsEnvironmentVariable.IsPresent) {
        Set-Variable -Name IWConfig -Value $config -Scope Script
        $Script:IWConfig.loaded = $true
    }
    
    if ([string]::IsNullOrEmpty($config)) {
        throw "Config is not valid. Please check $ConfigFile"
    }
    
    return $config
}

