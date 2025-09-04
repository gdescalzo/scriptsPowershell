
# Hyper-V Configuration Audit Script

Write-Host "=== Hyper-V Host Information ===" -ForegroundColor Cyan
Get-VMHost | Format-List

Write-Host "`n=== Virtual Switches ===" -ForegroundColor Cyan
Get-VMSwitch | Format-Table Name, SwitchType, NetAdapterInterfaceDescription

Write-Host "`n=== Virtual Machines ===" -ForegroundColor Cyan
Get-VM | Format-Table Name, State, CPUUsage, MemoryAssigned, Uptime

Write-Host "`n=== Supported VM Versions ===" -ForegroundColor Cyan
Get-VMHostSupportedVersion

Write-Host "`n=== System Resources ===" -ForegroundColor Cyan
Get-ComputerInfo | Select-Object CsTotalPhysicalMemory, CsNumberOfLogicalProcessors

Write-Host "`n=== VM Firmware Settings (all VMs) ===" -ForegroundColor Cyan
Get-VM | ForEach-Object {
    $vm = $_.Name
    Write-Host "Firmware for VM: $vm"
    Get-VMFirmware -VMName $vm | Format-List
}

Write-Host "`n=== VM DVD Drives (all VMs) ===" -ForegroundColor Cyan
Get-VM | ForEach-Object {
    $vm = $_.Name
    Write-Host "DVD drives for VM: $vm"
    Get-VMDvdDrive -VMName $vm | Format-Table ControllerNumber, ControllerLocation, Path
}

Write-Host "`n=== VM Processor Settings (all VMs) ===" -ForegroundColor Cyan
Get-VM | ForEach-Object {
    $vm = $_.Name
    Write-Host "Processor for VM: $vm"
    Get-VMProcessor -VMName $vm | Format-List Count, ExposeVirtualizationExtensions
}
