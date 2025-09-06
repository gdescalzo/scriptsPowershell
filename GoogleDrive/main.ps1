# Ruta del JSON en el mismo directorio que el script
$jsonPath = Join-Path $PSScriptRoot "config\config.json"

# Cargar y parsear JSON
$config = Get-Content $jsonPath | ConvertFrom-Json

# Usar las JSON keys como variables
foreach ($prop in $config.PSObject.Properties){
    Set-Variable -Name $prop.Name -Value $prop.Value -Scope Script
}

