# Install the required module
#Add-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0

$isoPath = "D:\ISOs\CustomCentOS.iso"
$centosPath = "D:\ISOs\CentOS-9" # path to the directory that contains the contents of the CentOS ISO
$ksFilePath = "C:\Users\gdesc\Documents\GitRepos\powershellScrips\scripts\Hyper-V\kickstart.cfg"

# create the new ISO image
New-IsoFile -InputObject $centosPath -Path $isoPath -BootImage $centosPath\images\pxeboot\vmlinuz -Media DVD -Force

# add the Kickstart file to the ISO image
$iso = [System.IO.File]::Open($isoPath, [System.IO.FileMode]::Open)
$isoStream = [System.IO.BinaryReader]::new($iso)
$isoContents = $isoStream.ReadBytes($isoStream.BaseStream.Length)
$isoStream.Close()
$iso.Close()
$iso = [System.IO.File]::OpenWrite($isoPath)
$isoStream = [System.IO.BinaryWriter]::new($iso)
$isoStream.Write($isoContents)
$ksFile = [System.IO.File]::OpenRead($ksFilePath)
$ksContents = $ksFile.ReadBytes($ksFile.Length)
$ksFile.Close()
$isoStream.Seek(0, [System.IO.SeekOrigin]::End)
$isoStream.Write($ksContents)
$isoStream.Close()
$iso.Close()