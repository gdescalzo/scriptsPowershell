<# Required manually login 
Connect-AzAccount #>

<# VARS #>
$SPNDisplayName = "testSPN"
$getSubs = (Get-AzSubscription).Name


foreach ($sub in $getSubs) {

    #Write-Output $sub

    Select-AzSubscription -SubscriptionName $sub 
    $spn = New-AzADServicePrincipal -DisplayName $SPNDisplayName
    $appId = $spn.ApplicationId
    $secret = New-AzADSpCredential -ObjectId $spn.Id

    Write-Output "For the Subscription:" + $sub`n + "has been created the SPN:" + $SPNDisplayName`n + "With the Application ID:" + $appId`n + "And the secret:" + $secret
}