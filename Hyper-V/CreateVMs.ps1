
    # Script to create multiple Hyper-V VMs with Ubuntu Server 22.04 live-server ISO downloaded and mounted.
    # This script requires the Hyper-V PowerShell module and administrative privileges to run.

    # Requires Hyper-V PowerShell module
    if (-not (Get-Module -Name Hyper-V -ListAvailable)) {
        Write-Error "Hyper-V module is not available. Please install it before running this script."
        exit 1
    }

    $separator  = "-"
    $vhdPath    = (Get-VMHost).VirtualHardDiskPath
    $vmPrefix   = Read-Host "Enter the VM name"
    $vmPrefix   += $separator
    $vmCount    = [int](Read-Host "Enter the number of VMs to create")
    $vmMemory   = [int](Read-Host "Enter the memory size per VM (in GB)")
    $vmCpuCount = [int](Read-Host "Enter the number of CPUs per VM")
    $diskSize   = [int](Read-Host "Enter the disk size per VM (in GB, numbers only)")

    # Switch selection
    $switchNames = @(Get-VMSwitch | Select-Object -ExpandProperty Name)
    if ($switchNames.Count -eq 0) {
        Write-Host "No virtual switches found. Please create one before running this script."
        exit
    }
    # Show switch selection options
    do {
        Write-Host "Select a virtual switch:"
        for ($i = 0; $i -lt $switchNames.Count; $i++) {
            Write-Host ("  {0}. {1}" -f ($i + 1), $switchNames[$i])
        }
        $selectedOption = [int](Read-Host "Enter the switch number")
    } while ($selectedOption -lt 1 -or $selectedOption -gt $switchNames.Count)
    $vmSwitchName = $switchNames[$selectedOption - 1]

    # Show free space on the drive where VHDs will be created
    $vhdDrive = $vhdPath.Substring(0, 2)
    $freeSpaceGB = [math]::Round((Get-PSDrive -Name $vhdDrive[0]).Free / 1GB, 2)
    Write-Host "Free space on drive ${vhdDrive}: $freeSpaceGB GB"

    # Download Ubuntu Server 22.04 live-server ISO
    $tempPath = [System.IO.Path]::GetTempPath()
    $baseUrl = "https://releases.ubuntu.com/22.04/"
    try {
        $html = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing
        $isoRelativePath = ($html.Links | Where-Object {
                $_.href -match "ubuntu-22\.04\.\d+-live-server-amd64\.iso"
            } | Select-Object -First 1).href

        if (-not $isoRelativePath) {
            Write-Error "No valid ISO file found on the release page."
            exit 1
        }

        $isoUrl = "$baseUrl$isoRelativePath"
        $isoFilename = Split-Path -Leaf $isoRelativePath
        $isoPath = Join-Path $tempPath $isoFilename

        if (-not (Test-Path $isoPath)) {
            Write-Host "Downloading ISO from: $isoUrl"
            Invoke-WebRequest -Uri $isoUrl -OutFile $isoPath
        }
        else {
            Write-Host "ISO already exists at: $isoPath"
        }
    }
    catch {
        Write-Error "Error while downloading ISO: $_"
        exit 1
    }

    # Create VMs
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
            Add-VMDvdDrive -VMName $vmName -Path $isoPath
            Start-VM -Name $vmName
        }
        else {
            Write-Host "Virtual machine already exists: $vmName, skipping creation."
        }
    }


    <# To delete easly
    $loop = (Get-VM | Select-Object -ExpandProperty Name)
    foreach ($item in $loop) { stop-vm $item -Force ; Remove-VM $item -Force }
    #>