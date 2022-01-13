#help and examples
get-help get-adcomputer 
get-help Get-ADComputer -Examples

#create computer accounts from a CSV file
import-csv .\computers.csv | new-adcomputer

#delete computer accounts from a CSV file
import-csv .\computers.csv | Foreach-Object {Remove-ADcomputer -Identity $_.SamAccountName -Confirm:$False }

#new ad computer account created
New-ADComputer -Name PC9 -Path "cn=computers,dc=atlantis,dc=local"