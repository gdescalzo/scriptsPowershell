#setting properties that are not common

New-ADUser MMariota -Description "Finance Manager" -OtherAttributes @{carLicense='xxy-asdf'}
Get-ADUser MMariota -Properties carLicense

Set-ADUser MMariota -Replace @{carLicense='TitanUp'}
Get-ADUser MMariota -Properties carLicense

Set-ADUser MMariota -clear carLicense
Get-ADUser MMariota -Properties carLicense

#get prompted for username of account to be unlocked or disabled
read-host "Enter the user account to unlock" | unlock-Adaccount
read-host "Enter the user account to unlock" | Disable-ADAccount