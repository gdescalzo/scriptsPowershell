#delete user account from CSV file
Import-Csv .\Users.csv | Foreach-Object {Remove-ADUser -Identity $_.SamAccountName -Confirm:$False }

#does not remove object. Informs what the command will do if executed
Get-ADUser -filter 'department -eq "hr"'| Remove-ADUser -whatif

#removes user account based on department
Get-ADUser -filter 'department -eq "hr"'| Remove-ADUser
Get-ADUser -filter 'department -eq "hr"'| Remove-ADUser -Confirm:$false

#Import users from CSV file
Import-Csv ".\users.csv" | New-ADUser -AccountPassword $(convertto-securestring "P@55w0rd" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true