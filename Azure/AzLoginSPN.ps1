<## VARS ##>
$Secret = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
$ApplicationId = "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"
$TenantId = "22222222222222222222222222222222222"

function AzConection {

    $SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
   
}

AzConection