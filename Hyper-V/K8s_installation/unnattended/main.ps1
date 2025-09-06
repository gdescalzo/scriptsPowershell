# Script to create multiple Hyper-V VMs with Ubuntu Server 22.04 live-server ISO and unattended installation for Kubernetes.
# Requires Hyper-V module and Windows ADK Deployment Tools (oscdimg.exe)

<# Import Variables #>
$VarsPath = Join-Path $PSScriptRoot 'vars\vars.ps1'
. $VarsPath

<# Import Modules #>
Get-ChildItem -Path $ModulesPath -Filter *.ps1 | ForEach-Object {                       # Import all .ps1 files into the modules directory
    . $_.FullName
}

<# Check Requirements #>
Write-Host "`n🔎 Running environment checks...`n"

Check-Host-Admin                                                                        # Check Administrator privileges
Check-Windows-Architecture                                                              # Check Windows Architecture
$checkADK = Check-Windows-ADK                                                           # Check Windows ADK status
if (-not $checkADK) {
    Write-Host "⚠️ Windows ADK not found. Installing..."
    $installResult = Install-WindowsADK                             # Install Windows ADK
    if (-not $installResult) {
        Write-Error "❌ Failed to install Windows ADK. Exiting..."
        exit 1
    }

    # Re-check after installation
    $checkADK = Check-Windows-ADK
    if (-not $checkADK) {
        Write-Error "❌ ADK installation completed, but Deployment Tools not detected. Exiting..."
        exit 1
    }
}
Write-Host "✅ Windows ADK (Deployment Tools) is available."
$checkHypervStatus = Check-HyperV-Status                                                # Check if Hyper-V is installed
if (-not $checkHypervStatus) { Install-HyperV }                                         # Install Hyper-V

<# Show Host Resources #>
Show-Host-Resources

<# User input (with defaults from JSON config) #>
Write-Host "`n⚙️  Enter the VM setup`n"

$vmPrefix = Read-Host "Enter the VM name [$hyperv_vmName]"                              # VM Name
if (-not $vmPrefix) { $vmPrefix = $hyperv_vmName }
$vmPrefix += $separator
[int]$vmCount = Read-Host "Enter the number of VMs to create [1]"                       # Number of VMs
if (-not $vmCount -or $vmCount -lt 1) { $vmCount = 1 }
[int]$vmMemory = Read-Host "Enter memory per VM in GB [$hyperv_vmMemory]"               # Memory per VM (GB)
if (-not $vmMemory -or $vmMemory -lt 1) { $vmMemory = $hyperv_vmMemory }
[int]$vmCpuCount = Read-Host "Enter number of CPUs per VM [$hyperv_vmCpuCount]"         # CPU count per VM
if (-not $vmCpuCount -or $vmCpuCount -lt 1) { $vmCpuCount = $hyperv_vmCpuCount }
[int]$vmDiskSize = Read-Host "Enter disk size per VM in GB [$hyperv_vmDiskSize]"        # Disk size per VM (GB)
if (-not $vmDiskSize -or $vmDiskSize -lt 1) { $vmDiskSize = $hyperv_vmDiskSize }
$availableSwitches = Get-HypervSwitchNames                                              # Get available virtual switches
Write-Host "`n🌐 Available Hyper-V Virtual Switches:`n"
for ($i = 0; $i -lt $availableSwitches.Count; $i++) {
    Write-Host "[$i] $($availableSwitches[$i])"
}
$defaultIndex = $availableSwitches.IndexOf($hyperv_switchName)                          # Default switch index (based on JSON default)
if ($defaultIndex -lt 0) { $defaultIndex = 0 }
[int]$switchIndex = Read-Host "Enter the number of the switch to use [$defaultIndex]"   # Ask user to select a switch
if (-not $switchIndex -or $switchIndex -lt 0 -or $switchIndex -ge $availableSwitches.Count) {
    $switchIndex = $defaultIndex
}
$vmSwitch = $availableSwitches[$switchIndex]
Write-Host "`n✅ Selected virtual switch: $vmSwitch"

<# Download Ubuntu Server 22.04 live-server ISO #>
Write-Host "`n💿 Preparing Ubuntu ISO...`n"
$isoPath = Ubuntu-ISO-Download
Write-Host "✅ ISO ready at: $isoPath"

<# Create Cloud-Init ISO #>
Write-Host "💿 Creating Cloud-Init ISO..." -ForegroundColor Yellow
$cloudInitISO = New-CloudInitISO

if (-not (Test-Path $cloudInitISO)) {
    Write-Error "❌ Creating cloud init.iso failed. Abort execution."
    exit 1
}

Write-Host "✅ Cloud-Init ISO created on: $cloudInitISO" -ForegroundColor Green


<# --- Create VMs ---
for ($i = 1; $i -le $vmCount; $i++) {
    $vmName = "$vmPrefix$i"
    $vmVHDname = "$vmPrefix$i"
    $vmVhdPath = "$vhdPath\$vmVHDname.vhdx"

    if (-Not (Test-Path $vmVhdPath)) {
        Write-Host "Creating virtual hard disk: $vmVhdPath"
        New-VHD -Path $vmVhdPath -SizeBytes ($diskSize * 1GB) -Dynamic
    }
    else {
        Write-Host "Virtual hard disk already exists: $vmVhdPath, skipping creation."
    }

    if (-Not (Get-VM -Name $vmName -ErrorAction SilentlyContinue)) {
        Write-Host "Creating virtual machine: $vmName"
        New-VM -Name $vmName -MemoryStartupBytes ($vmMemory * 1GB) `
            -SwitchName $vmSwitchName -VHDPath $vmVhdPath `
            -Generation 2

        Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
        Set-VMProcessor -VMName $vmName -Count $vmCpuCount
        Set-VMProcessor -VMName $vmName -ExposeVirtualizationExtensions $true

        # --- Cloud-init ---
        $cloudInitDir = "C:\cloudinit\$vmName"
        New-Item -ItemType Directory -Path $cloudInitDir -Force | Out-Null

        @"
instance-id: $vmName
local-hostname: $vmName
"@ | Out-File -FilePath "$cloudInitDir\meta-data" -Encoding UTF8

        @"
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: $vmName
    username: ubuntu
    password: "<SHA512_PASSWORD_HASH>"
  ssh:
    install-server: true
    authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...
  storage:
    layout:
      name: lvm
  packages:
    - apt-transport-https
    - ca-certificates
    - curl
    - gnupg
    - lsb-release
    - containerd
  late-commands:
    - curtin in-target --target=/target swapoff -a
    - curtin in-target --target=/target sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    - curtin in-target --target=/target mkdir -p /etc/containerd
    - curtin in-target --target=/target bash -c "containerd config default > /etc/containerd/config.toml"
    - curtin in-target --target=/target sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    - curtin in-target --target=/target systemctl enable containerd
    - curtin in-target --target=/target curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key
    - curtin in-target --target=/target bash -c "echo 'deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' > /etc/apt/sources.list.d/kubernetes.list"
    - curtin in-target --target=/target apt-get update
    - curtin in-target --target=/target apt-get install -y kubelet kubeadm kubectl
    - curtin in-target --target=/target apt-mark hold kubelet kubeadm kubectl
    - curtin in-target --target=/target bash -c "echo 'net.bridge.bridge-nf-call-iptables=1' > /etc/sysctl.d/k8s.conf"
    - curtin in-target --target=/target bash -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.d/k8s.conf"
    - curtin in-target --target=/target sysctl --system
"@ | Out-File -FilePath "$cloudInitDir\user-data" -Encoding UTF8

        # --- Create seed ISO with correct volume label for autoinstall ---
        $seedIsoPath = "$vhdPath\$vmName-seed.iso"
        & "$oscdimgPath" -n -m -o -l cidata "$cloudInitDir" "$seedIsoPath"

        # --- Mount ISOs and start VM ---
        Add-VMDvdDrive -VMName $vmName -Path $isoPath
        Add-VMDvdDrive -VMName $vmName -Path $seedIsoPath
        Start-VM -Name $vmName
    }
    else {
        Write-Host "Virtual machine already exists: $vmName, skipping creation."
    }
}
#>