<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Get available Hyper-V switches #>
function Get-HypervSwitchNames {
    try {
        $switches = Get-VMSwitch | Select-Object -ExpandProperty Name
        if ($switches) {
            return $switches
        }
        else {
            Write-Warning "⚠️ No Hyper-V virtual switches found."
            return @()
        }
    }
    catch {
        Write-Error "❌ Error retrieving Hyper-V switches: $_"
        return @()
    }
}

<# Install Hyper-V #>
function Install-HyperV {
    Write-Host "⬇️ Installing Hyper-V..."
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart -ErrorAction Stop
        Write-Host "✅ Hyper-V installation initiated successfully."

        # Ask if you want to restart
        $restart = Read-Host "Do you want to restart the computer now to complete installation? (Y/N)"
        if ($restart -match '^[Yy]') {
            Write-Host "🔄 Restarting computer..."
            Restart-Computer
        }
        else {
            Write-Host "⚠️ Please restart your system later to complete Hyper-V installation."
        }
    }
    catch {
        Write-Error "❌ Failed to install Hyper-V: $_"
        exit 1
    }
}
