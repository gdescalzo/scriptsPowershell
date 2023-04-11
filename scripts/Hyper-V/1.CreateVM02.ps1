$count = 0
$separator = "-"
$vhdPath = (Get-VMHost).VirtualHardDiskPath
$vmPrefix = Read-Host "Enter the VM Name"
$vmName = $vmPrefix + $separator
$vmCount = Read-Host "Enter the VM count"
$vmMemory = Read-Host "Enter the VM Memory size" 
$vmMemory = $vmMemory + "GB"
$vmCpuCount = Read-Host "Enter the VM CPU count"

$switchNames = Get-VMSwitch -Name "*" | Select-Object -ExpandProperty Name
do {
    Write-Host "Select a virtual switch:"
    for ($i = 0; $i -lt $switchNames.Count; $i++) {
        Write-Host "  $($i+1). $($switchNames[$i])"
    }
    $selectedOption = Read-Host "Enter the number of the switch"
    $selectedOption = [int]$selectedOption
} while ($selectedOption -lt 1 -or $selectedOption -gt $switchNames.Count)
$selectedSwitch = $switchNames[$selectedOption - 1]
$vmSwitchName = $selectedSwitch

function Get-FreeSpace {
    $vhdxPath = (Get-VMHost).VirtualHardDiskPath | Select-Object -First 1 | Split-Path -Qualifier
    $drive = Get-PSDrive -Name $vhdxPath.Substring(0, 1)
    $freeSpaceInGB = [Math]::Round(($drive.Free / 1GB), 2)
    Write-Host "Free space on drive $($vhdxPath.Substring(0,1)): $freeSpaceInGB GB"
}

do {
    Get-FreeSpace
    $diskSize = Read-Host "Enter the VM disk size (in GB, please input only numbers)"
} while (-not ([int]::TryParse($diskSize, [ref]$null)))
$diskSize = $diskSize + "GB"

function Get-NextVMNumber {
    param (
        [string] $vmName
    )
    try {
        $existingVMs = Get-VM | Where-Object { $_.Name -like "$vmName*" } | Select-Object -ExpandProperty Name
        $vmNumbers = $existingVMs -replace "^$vmName", "" | ForEach-Object { [int]$_ }
        $nextVmNumber = if ($vmNumbers) { ($vmNumbers | Measure-Object -Maximum).Maximum + 1 } else { 1 }
    }
    catch {
        Write-Error $_.Exception.Message
        $nextVmNumber = 1
    }
    return $nextVmNumber
}
$nextVmNumber = Get-NextVMNumber -vmName $vmName

function Get-NextVhdNumber {
    param (
        [string]$VhdPath,
        [string]$VmName
    )
    try {
        $existingVHD = (Get-VHD ($VhdPath + "*.vhdx") | Select-Object -ExpandProperty Path) -replace [regex]::Escape($VhdPath), '' -replace [regex]::Escape($VmName), '' -replace [regex]::Escape(".vhdx"), ''   
        $vhdNumbers = $existingVHD | ForEach-Object { [int]$_ }
        $nextVhdNumber = if ($vhdNumbers) { ($vhdNumbers | Measure-Object -Maximum).Maximum + 1 } else { 1 }
        
    }
    catch {
        Write-Error $_.Exception.Message
        $nextVhdNumber = 1
    }
    return $nextVhdNumber
}
$nextVhdNumbers = Get-NextVhdNumber -vhdPath $vhdPath -vmName $vmName

while ($count -ne $vmCount) {

    $vmName = $vmName + $nextVmNumber.ToString() 
    $vmVHDname = $vmPrefix + $separator + $nextVhdNumbers.ToString() 
    $vmVhdPath = $vhdPath + "$vmVHDname.vhdx" 

    <# Create the virtual hard disk #>
    New-VHD -Path $vmVhdPath -SizeBytes $diskSize  -Dynamic

    <# Create the virtual machine #>
    New-VM -Name $vmName -MemoryStartupBytes $vmMemory -SwitchName $vmSwitchName -VHDPath $vmVhdPath -Generation 2 -BootDevice VHD 

    <# Disable Secure Boot in the firmware settings #>
    Set-VMFirmware -VMName $vmName -EnableSecureBoot Off 

    <# Set virtual machine processor count #>
    Set-VMProcessor -VMName $vmName -Count $vmCpuCount 

    <# Start the virtual machine #>
    Start-VM -Name $vmName

    $count++ ;
    $nextVmNumber++ ;
    $nextVhdNumbers++ ;
    $vmName = $vmPrefix + $separator
    $vmVHDname = $vmPrefix + $separator   
}