#Help and Examples
get-help search-adaccount
get-help search-adaccount -examples 

#search for user accounts
Search-ADAccount -AccountInactive -UsersOnly -DateTime '10/01/2017' 
Search-ADAccount -AccountInactive -UsersOnly -DateTime '10/01/2017' | ogv
Search-ADAccount -AccountInactive -UsersOnly -TimeSpan (New-TimeSpan -Days 90) | ogv
Get-ADUser -filter * -Properties samaccountname, enabled, lastlogondate, logoncount | ogv

#Search for computer accounts
Search-ADAccount -AccountInactive -ComputersOnly
Search-ADAccount -AccountInactive -ComputersOnly -DateTime '10/01/2017' 
Search-ADAccount -AccountInactive -ComputersOnly -DateTime '10/01/2017' | ogv
Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan (New-TimeSpan -days 90) | ogv
Search-ADAccount -AccountDisabled -ComputersOnly