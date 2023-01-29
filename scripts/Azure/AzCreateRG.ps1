## VARS
$Secret = "UIc8Q~IsxLBanGJcKdKhYMGa2xG7zByu1vsR5b9B"
$ApplicationId = "e1ee79fc-976d-4d29-97e6-e935abf7d333"
$TenantId = "2456b851-46fd-4293-907c-d1d81c679af6"
$SubscriptionId = "794c4aed-01e7-4a3f-b64d-4d4b02022224"
$myResourceGroup = "GSV-RG"
$azContext = Set-AzContext -SubscriptionId $SubscriptionId

function AzConection {

    $SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
   
}
function AzCreateRG {
    Get-AzResourceGroup -Name $myResourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if ($notPresent) {
        New-AzResourceGroup -Name $myResourceGroup -Location eastus
    }
    else {
        Write-Output "ResourceGroup exist"
    }        
}

AzConection 

$azContext

AzCreateRG