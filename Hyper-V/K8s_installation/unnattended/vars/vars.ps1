<# Import JSON #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                                       # Detect project root 
$VarsPath = Join-Path $ProjectRoot 'config\config.json'                                     # Build path to config.json
$Config = Get-Content $VarsPath -Raw | ConvertFrom-Json                                     # Load JSON
<# Generate global variables automatically #>
foreach ($section in $Config.PSObject.Properties) {
    foreach ($item in $section.Value.PSObject.Properties) {
        $varName = "$($section.Name)_$($item.Name)"  
        Set-Variable -Name $varName -Value $item.Value -Scope Global
    }
}                                     

<# Script #>
$ModulesPath = Join-Path $ProjectRoot 'modules'
$separator = "-"

