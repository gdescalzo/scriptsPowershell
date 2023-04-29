$credential = New-Object System.Management.Automation.PSCredential("some@email.com", ("YourPassword!" | ConvertTo-SecureString -AsPlainText -Force))
Connect-AzAccount -Credential $credential
