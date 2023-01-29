## VARS

$Secret = "UIc8Q~IsxLBanGJcKdKhYMGa2xG7zByu1vsR5b9B"
$ApplicationId = "e1ee79fc-976d-4d29-97e6-e935abf7d333"
$TenantId = "2456b851-46fd-4293-907c-d1d81c679af6"
$SubscriptionId = "794c4aed-01e7-4a3f-b64d-4d4b02022224"


function AzConection {

    $SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
   
}

AzConection 

Set-AzContext -SubscriptionId $SubscriptionId