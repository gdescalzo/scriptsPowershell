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

<# Hyper-V #>
$HypervValidation       = (Get-Module -ListAvailable -Name Hyper-V) -ne $null                   # Check if the Hyper-V module is present on the host.
$HypervVHDPath          = (Get-VMHost).VirtualHardDiskPath                                      # Default path for virtual disks on the host.
$HypervVHDDrive         = $HypervVHDPath.Substring(0, 2)                                        # Drive letter where the VHD path is located
$HypervSwitchNames      = @(Get-VMSwitch | Select-Object -ExpandProperty Name)                  # List of available virtual switches.


<# Host #>
$HostTempPath       = [System.IO.Path]::GetTempPath()                                                               # Default system temporary directory path.
$HostFreeSpaceGB    = [math]::Round((Get-PSDrive -Name $HypervVHDDrive[0]).Free / 1GB, 2)                           # Free space on the drive where the disks are stored.
$HostFreeMemoryGB   = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024 / 1024, 2)    # Free memory in GB

<# Windows ADK #>
$HostInstalledProductsWMI = Get-WmiObject -Class Win32_Product | Select-Object -ExpandProperty Name                     # Installed products detected via WMI
$HostInstalledProductsCIM = Get-CimInstance -ClassName Win32_Product | Select-Object -ExpandProperty Name               # Installed products detected via CIM
$InstalledProductsReg64 = (Get-ItemProperty -Path $host_registry64 -ErrorAction SilentlyContinue).DisplayName | Where-Object { $_ } # Installed products detected via Windows Registry
$InstalledProductsReg32 = (Get-ItemProperty -Path $host_registry32 -ErrorAction SilentlyContinue).DisplayName | Where-Object { $_ } # Installed products detected via Windows Registry
$HostInstalledProductsReg = $InstalledProductsReg64 + $InstalledProductsReg32                                           # Installed products detected via Windows Registry
$InstallerPath = Join-Path $HostTempPath "adksetup.exe"

<# Script #>
$ModulesPath = Join-Path $ProjectRoot 'modules'
$separator = "-"

