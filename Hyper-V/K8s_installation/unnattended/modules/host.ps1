<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Get system temporary directory path #>
function Get-HostTempPath {
    return [System.IO.Path]::GetTempPath()
}

<# Host memory helper #>
function Get-HostFreeMemoryGB {
    return [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024 / 1024, 2)
}

<# Host information helpers #>
function Get-HypervVHDPath {
    return (Get-VMHost).VirtualHardDiskPath
}

function Get-HypervVHDDrive {
    $path = Get-HypervVHDPath
    return $path.Substring(0, 2)
}

function Get-HostFreeSpaceGB {
    $drive = Get-HypervVHDDrive
    return [math]::Round((Get-PSDrive -Name $drive.TrimEnd(':')).Free / 1GB, 2)
}

<# Host installed products helpers #>
function Get-HostInstalledProductsWMI {
    return Get-WmiObject -Class Win32_Product | Select-Object -ExpandProperty Name
}

function Get-HostInstalledProductsCIM {
    return Get-CimInstance -ClassName Win32_Product | Select-Object -ExpandProperty Name
}

function Get-InstalledProductsReg64 {
    param([string]$RegistryPath = $host_registry64)
    return (Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue).DisplayName | Where-Object { $_ }
}

function Get-InstalledProductsReg32 {
    param([string]$RegistryPath = $host_registry32)
    return (Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue).DisplayName | Where-Object { $_ }
}

function Get-HostInstalledProductsReg {
    $reg64 = Get-InstalledProductsReg64
    $reg32 = Get-InstalledProductsReg32
    return $reg64 + $reg32
}

<# Install Windows ADK #>
function Install-WindowsADK {

    $InstallerPath = Join-Path (Get-HostTempPath) "adksetup.exe"

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

