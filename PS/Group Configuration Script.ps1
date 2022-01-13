#help information about adgroup command
get-help get-adgroup

#retreives the root domain name
$rootDN = (get-ADdomain).DistinguishedName

#creates a new ad group in the parent domain named sales users and adds members
New-ADGroup -Path "ou=Sales,$rootDN" -name "Sales Users" -GroupScope Global -GroupCategory Security 
Add-ADGroupMember -Identity "Sales Users" -Members (get-aduser TBrady)
Remove-ADGroupMember -Identity "Sales Users" -Members (get-aduser TBrady)
Get-ADGroup "sales Users"

Get-ADGroup "sales users" 
Add-ADGroupMember -Identity "sales users" -Members (get-aduser -Filter 'department -eq "hr"')
Get-ADGroupMember "sales users"
Get-ADGroupMember "sales users" | ogv
Remove-ADGroup "sales users"


