Install-ADDSDomainController -SkipPreChecks -DomainName atlantis.local `
 -SiteName defaul-first-site-name -DatabasePath c:\windows\ntds `
  -LogPath c:\windows\ntds -SysvolPath c:windows\sysvol -InstallDns