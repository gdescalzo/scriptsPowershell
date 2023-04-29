$pattern = "VM"

<# Get the existing VM names and extract the numbers
$existingVMs = Get-VM | Select-Object -ExpandProperty Name
$existingNumbers = $existingVMs | Where-Object { $_ -match "^$vmPrefix(\d+)$" } | ForEach-Object { [int]$Matches[1] } | Sort-Object
#>

<# Set variables #>
$count = 0
$counter = 4
$pattern = "VM"

$vmMemory = 8GB
$vmCpuCount = 2
$vmSwitchName = "External Switch" 

while ($count -ne $counter) {
   
    $count++ ;

    $vmName = $pattern + "-" + $count

    $vmVhdPath = (Get-VMHost).VirtualHardDiskPath + "$vmName.vhdx"

    <# Create the virtual hard disk #>
    New-VHD -Path $vmVhdPath -SizeBytes 50GB -Dynamic

    <# Create the virtual machine #>
    New-VM -Name $vmName -MemoryStartupBytes $vmMemory -SwitchName $vmSwitchName -VHDPath $vmVhdPath -Generation 2 -BootDevice VHD 

    <# Disable Secure Boot in the firmware settings #>
    Set-VMFirmware -VMName $vmName -EnableSecureBoot Off

    <# Set virtual machine processor count #>
    Set-VMProcessor -VMName $vmName -Count $vmCpuCount

    <# Start the virtual machine #>
    Start-VM -Name $vmName

}

<# To delete easly
$loop = (Get-VM | Select-Object -ExpandProperty Name)
foreach ($item in $loop) { stop-vm $item -Force ; Remove-VM $item -Force }
#>