<# Set SRE SPN Context #>
$spnID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$spnKey = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$spnTenantId = "wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"

Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
    return $authorization
}

Function Set-SPNAccount {
    param(
        $spnID,
        $spnKey,
        $spnTenantId
    )
    $password = ConvertTo-SecureString $spnKey -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($spnID, $password)
    Login-AzAccount -ServicePrincipal -Credential $Cred -Tenant $spnTenantId -WarningAction Ignore | Out-Null
}

Set-SPNAccount -spnID $spnID -spnKey $spnKey -spnTenantId $spnTenantId

# Define the list of SPN names to check
$SPNlist = @("222222222222222222222", "333333333333333", "4444444444444444444", "555555555555555555555", "666666666666666666", "7777777777777777", "88888888888", "9999999999999999", "11111111111111", "aaaaaaaaaaaaaaaa", "sssssssssssss", "vvvvvvvvvvvvvvv", "zzzzzzzzzzzzz", "bbbbbbbbbbbb")


$queryLists = $SPNlist.split(',')

foreach ($SPN in $queryLists) {

    $AppIds = Get-AzADServicePrincipal -SearchString  $SPN | Select-Object AppId

    foreach ($AppID in $AppIds ) {

        $Appid = $AppID.AppId

        #az ad app credential list --id $Appid
        Get-AzADAppCredential -ApplicationId $Appid   EndDateTime

    }

}