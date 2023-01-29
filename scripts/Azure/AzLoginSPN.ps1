<# Azure SPN (GSV-Enterprise)

SPN Name			: SPN-GSV-Enterprise
SPN Secret Name		: SPN-GSV-Enterprise-ClientSecret
SPN Secret Value    : UIc8Q~IsxLBanGJcKdKhYMGa2xG7zByu1vsR5b9B	
SPN Secret ID		: ea9511ad-6ab9-4726-bf6d-340b588b442e
SPN Application ID	: e1ee79fc-976d-4d29-97e6-e935abf7d333

#>

$Secret = "UIc8Q~IsxLBanGJcKdKhYMGa2xG7zByu1vsR5b9B"
$ApplicationId = "e1ee79fc-976d-4d29-97e6-e935abf7d333"
$TenantId = "2456b851-46fd-4293-907c-d1d81c679af6"

$SecuredPassword = ConvertTo-SecureString $Secret -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecuredPassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential


Get-AzSubscription

Get-AzContext