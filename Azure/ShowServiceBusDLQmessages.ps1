<# Set SRE SPN Context #>
$spnID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$spnKey = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$spnTenantId = "wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"


$password = ConvertTo-SecureString $spnKey -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($spnID, $password)

<# Set Customer Context #>
$customerSubscripton = Get-AutomationVariable -Name 'xxxxxxxxxxxxxxxxxxxxxxxxxx'
$customerResourceGroup = Get-AutomationVariable -Name 'zzzzzzzzzzzzzzzzzzzzzzzz'

<# Login #>
Login-AzAccount -ServicePrincipal -Credential $Cred -Tenant $spnTenantId -WarningAction SilentlyContinue 4>$null | Out-Null
Set-AzContext -Subscription $customerSubscripton | Out-Null

$sbs = Get-AzServiceBusSubscription -ResourceGroupName $customerResourceGroup -NamespaceName USCPEYMP52BUS05 -TopicName aaaaaaaaaaa -name wwwwwwwwwwww

Write-Output $sbs.CountDetailDeadLetterMessageCount

