<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Get system temporary directory path #>
function Get-HostTempPath {
    return [System.IO.Path]::GetTempPath()
}

<# Host CPU helper #>
function Get-HostCpuCount {
    return (Get-CimInstance Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
}

<# Host total memory helper #>
function Get-HostTotalMemoryGB {
    return [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
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

function Show-Host-Resources {
    Write-Host "`n🖥️  Host resources summary`n"

    $freeMem = Get-HostFreeMemoryGB
    $cpuCount = Get-HostCpuCount
    $totalMem = Get-HostTotalMemoryGB
    $tempPath = Get-HostTempPath
    $freeDisk = Get-HostFreeSpaceGB

    Write-Host " - Total Memory: $totalMem GB"
    Write-Host " - Free Memory:  $freeMem GB"
    Write-Host " - CPU Cores:    $cpuCount"
    Write-Host " - Free Disk:    $freeDisk GB"
    Write-Host " - Temp Path:    $tempPath"
}

<# Install Windows ADK (Base + Deployment Tools) #>
function Install-WindowsADK {

    $InstallerPath = Join-Path (Get-HostTempPath) "adksetup.exe"
    $DeploymentToolsPath = Join-Path (Get-HostTempPath) "adkdeploysetup.exe"

    # Download ADK bootstrap
    if (-not (Test-Path $InstallerPath)) {
        Write-Host "📥 Downloading Windows ADK installer..."
        Invoke-WebRequest -Uri $host_BaseURL -OutFile $InstallerPath
    }
    else {
        Write-Host "⚠️ ADK installer already exists at $InstallerPath"
    }

    # Install ADK silently
    Write-Host "⚙️ Installing Windows ADK base..."
    Start-Process -FilePath $InstallerPath -ArgumentList $host_InstallArg -Wait -NoNewWindow

    # Download ADK Deployment Tools bootstrap
    if (-not (Test-Path $DeploymentToolsPath)) {
        Write-Host "📥 Downloading Windows ADK Deployment Tools installer..."
        Invoke-WebRequest -Uri $host_DeploymentURL -OutFile $DeploymentToolsPath
    }
    else {
        Write-Host "⚠️ Deployment Tools installer already exists at $DeploymentToolsPath"
    }

    # Install Deployment Tools silently
    Write-Host "⚙️ Installing Windows ADK Deployment Tools..."
    Start-Process -FilePath $DeploymentToolsPath -ArgumentList $host_InstallArg -Wait -NoNewWindow

    Write-Host "✅ Windows ADK (Base + Deployment Tools) installed successfully."
    return $true
}


