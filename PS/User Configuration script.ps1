#help for user commands
get-help get-aduser
get-help get-aduser -Examples
get-command -Syntax New-ADUser

#prompts for username and required parameters to create a new user
New-ADUser

#creates a username Ron
New-ADUser ron -Office Boston -Company Atlantis -mobilephone "(123)987-4254"
Get-ADUser ron
Get-ADUser ron -Property *

#create a new user account, then modifies the description of the user.
New-ADUser "Bob Ross"
Set-ADObject -Description "Graphic Designer"

#New Accounts are disabled by default.  The enable below will FAIL
Enable-ADAccount ron

#use a variable to be prompted for the password, then set the password for the user.
$pw = Read-Host "what is the password" -AsSecureString
Set-ADAccountpassword ron -NewPassword $pw
Enable-ADAccount ron

New-ADUser Jim -Enabled $true -AccountPassword $(convertto-securestring "Pa55w0rd" -AsPlainText -Force)
Get-ADUser jim

#view users from csv file
Import-Csv ".\users.csv" | Out-GridView

Import-Csv ".\users.csv" | New-ADUser -AccountPassword $(convertto-securestring "P@55w0rd" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true

Import-Csv ".\users.csv" |
    New-ADUser `
    -enabled $true `
    -accountpassword $(convertTo-SecureString "Pa55w.rd" -AsPlainText -Force)

