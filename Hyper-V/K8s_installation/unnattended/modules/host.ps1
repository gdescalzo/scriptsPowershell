<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Install Windows ADK #>
function Install-WindowsADK {

    # Check if the installer already exists
    if (Test-Path $InstallerPath) {
        Write-Host "⚠️ Windows ADK Installer already exists in $InstallerPath, will not be downloaded again."
    }
    else {
        Write-Host "📥 Download Windows ADK installer from $host_BaseURL..."
        try {
            Invoke-WebRequest -Uri $host_BaseURL -OutFile $InstallerPath
            Write-Host "✅ Installer downloaded at $InstallerPath"
        }
        catch {
            Write-Error "❌ Error downloading the Windows ADK installer: $_"
            return $false
        }
    }

    Write-Host "⚙️ Running silent installation of Windows ADK (Deployment Tools)..."
    try {
        Start-Process -FilePath $InstallerPath -ArgumentList $host_InstallArg -Wait -NoNewWindow
        Write-Host "✅ Windows ADK (Deployment Tools) installed successfully."
        return $true
    }
    catch {
        Write-Error "❌ Error installing Windows ADK: $_"
        return $false
    }
}
