<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Check: Hyper-V installation status #>
function Check-HyperV-Status {
    
    $HypervValidation = (Get-Module -ListAvailable -Name Hyper-V) -ne $null     # Check if the Hyper-V module is present on the host.

    if (-not $HypervValidation) {
        Write-Error "❌ Hyper-V module is not available. Please install it before running this script."
        exit 1
    }

    Write-Host "✅ Hyper-V module is available."
    return $true
}

<# Check: Windows ADK status #>
function Check-Windows-ADK {

    # Patterns of the main components of the Windows ADK
    $adkPatterns = @(
        "Windows Assessment and Deployment Kit",
        "Windows Deployment Tools",
        "Windows System Image Manager"
    )

    # Filtering using host.ps1 functions
    $adkWMI = Get-HostInstalledProductsWMI | Where-Object { 
        $name = $_
        $adkPatterns | ForEach-Object { $name -like "*$_*" } | Where-Object { $_ } 
    }

    $adkCIM = Get-HostInstalledProductsCIM | Where-Object { 
        $name = $_
        $adkPatterns | ForEach-Object { $name -like "*$_*" } | Where-Object { $_ } 
    }

    $adkReg = Get-HostInstalledProductsReg | Where-Object { 
        $name = $_
        $adkPatterns | ForEach-Object { $name -like "*$_*" } | Where-Object { $_ } 
    }

    # Validation: not detected
    if (-not $adkWMI -and -not $adkCIM -and -not $adkReg) {
        Write-Error "❌ Windows ADK (Deployment Tools) is not installed or was not detected by any method."
        return $false
    }

    # Show results
    Write-Host "✅ Windows ADK detectado:"
    if ($adkWMI) { Write-Host " - WMI: $(( $adkWMI | Sort-Object -Unique ) -join ', ')" }
    if ($adkCIM) { Write-Host " - CIM: $(( $adkCIM | Sort-Object -Unique ) -join ', ')" }
    if ($adkReg) { Write-Host " - Registro: $(( $adkReg | Sort-Object -Unique ) -join ', ')" }

    return $true
}

<# Check: Administrator privileges #>
function Check-Host-Admin {
    # $IsAdmin will be $true if the user is an administrator
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $IsAdmin) {
        Write-Error "❌ This script must be run with administrator privileges. Please open PowerShell or VSCode as Administrator."
        exit 1
    }

    Write-Host "✅ Script running with administrator privileges."
    return $true
}

<# Check: Windows Architecture #>
function Check-Windows-Architecture {
    # Detects operating system architecture
    $arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture

    if ($arch -notlike "*64*") {
        Write-Warning "⚠ This script was tested on 64-bit Windows. The current host is:"
        # exit 1
    }
    else {
        Write-Host "✅ System architecture:"
    }

    return $arch
}