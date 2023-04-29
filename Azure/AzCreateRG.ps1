

<## VARS ##>
$Secret = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
$ApplicationId = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
$TenantId = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
$SubscriptionId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$AzContext = Set-AzContext -SubscriptionId $SubscriptionId

$myResourceGroup = "GSV-RGVPN01"

function AzConection {

    $SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
   
}
function AzCreateRG {
    Get-AzResourceGroup -Name $myResourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if ($notPresent) {
        New-AzResourceGroup -Name $myResourceGroup -Location brazilsouth
    }
    else {
        Write-Output "ResourceGroup exist, try with other name, peach."
    }        
}

AzConection 

$AzContext

AzCreateRG