Install-ADDSDomainController -SkipPreChecks -DomainName gsventerprise.com.ar `
 -SiteName GSV-Tribunales -DatabasePath c:\windows\ntds `
 -LogPath c:\windows\ntds -SysvolPath c:windows\sysvol -InstallDns `
 -NoRebootOnCompletion:$false -Force:$true