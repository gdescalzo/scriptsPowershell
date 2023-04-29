$vhdxPath = (Get-VMHost).VirtualHardDiskPath | Select-Object -First 1 | Split-Path -Qualifier
$drive = Get-PSDrive -Name $vhdxPath.Substring(0, 1)
$freeSpaceInGB = [Math]::Round(($freeSpace / 1GB), 2)
Write-Host "Free space on drive $($vhdxPath.Substring(0,1)): $freeSpaceInGB GB"

function Get-FreeMemory {
    $freeMemoryInBytes = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory
    $freeMemoryInMB = [Math]::Round(($freeMemoryInBytes / 1MB), 2)
    Write-Host "Free memory: $freeMemoryInMB MB"
}



