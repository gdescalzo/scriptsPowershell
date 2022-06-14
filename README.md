## powershellScrips
 This repo have powershell scripts for install or deploy stuff on w2kxx

### Pre-requisites

You will have to enable on the remote host the remote authentication for PowerShell 

    `Enable-PSRemoting -Force`

### Install system components

     sudo apt-get update
     sudo apt-get install -y curl gnupg apt-transport-https

### Import the public repository GPG keys

    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

### Register the Microsoft Product feed
    
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'

### Update the list of products
     
     sudo apt-get update

### Install PowerShell

    sudo apt-get install -y powershell

### Start PowerShell

    pwsh
