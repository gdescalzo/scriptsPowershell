## Connect Remote server for administration.
Enter-PSSession 192.168.122.230 -Credential Administrator -Authentication Negotiate -Verbose

## Installing the forest
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -DomainMode “Win2012R2” -DomainName “someDomain.locals” -DomainNetbiosName “SomeDomainName” -ForestMode “Win2012R2” -InstallDns:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -SysvolPath “C:\Windows\SYSVOL” -Force:$true 

## Check if the forest has been created.
Get-ADDomainController –filter *| format-table

## Install RSAT (GUI for manage AD)
install-windowsfeature rsat


