$credential = New-Object System.Management.Automation.PSCredential("gdescalzo@outlook.com", ("F1surado22!" | ConvertTo-SecureString -AsPlainText -Force))
Connect-AzAccount -Credential $credential
