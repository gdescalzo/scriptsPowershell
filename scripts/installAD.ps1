
## Connect Remote server for administration.
#$pwd1 = ConvertTo-SecureString "n0T1ad0y" -AsPlainText -Force  
#$cred = New-Object System.Management.Automation.PSCredential (".\Administrator",$pwd1)
#Enter-PSSession -ComputerName 192.168.122.230 -credential $cred


#Enter-PSSession 192.168.122.230 -Credential Administrator -Authentication Negotiate -Verbose

## Installing the Active Directory Domain Service

#install-windowsfeature -name AD-Domain-Services -IncludeManagementTools
#install-windowsfeature AD-Domain-Services

## Importing the Required Modules

#Import-Module ADDSDeployment