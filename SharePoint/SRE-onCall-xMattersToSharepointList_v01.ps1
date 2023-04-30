## xMatters
# xMatters Credentials
$user = 'x-api-key-xxxxxxxxxxxxxxxxxxxxxxxxxx'
$pass = ConvertTo-SecureString 'aaaaaaaaaaaaaaaaaaaaaaaa' -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass

$idGroup_a = "wwwwwwwwwwwwwwwwwwwwwwwwwwwww" #ARGENTINA
$idGroup_b = "ooooooooooooooooooooooooooooo" #INDIA
$xMattersIDgroup = @{
    shift_a = $idGroup_a + "&membersPerShift=1"
    shift_b = $idGroup_b + "&membersPerShift=1"
}

# xMatters URL
$tenant = "xxxxxxxxxxxx"
$xMattersApiURL = "https://" + $tenant + ".xmatters.com/api/xm/1/on-call?groups="
$urls = @{

    a = $xMattersApiURL + $xMattersIDgroup.shift_a
    b = $xMattersApiURL + $xMattersIDgroup.shift_b
}
$urlsArray = $urls.a , $urls.b

$idItem = 0

foreach ($url in $urlsArray)
{
    $req      = Invoke-WebRequest -Credential $cred -Uri $url -ContentType application/json -Method Get -UseBasicParsing | Select-Object -Expand Content

    $reqSplit = $req -split "," | sort
    $fname    = $reqSplit | Select-String "firstName" 
    $lname    = $reqSplit | Select-String "lastName"
    $tzone    = $reqSplit | Select-String "timezone"
    if ($idItem -eq 1){
            $tname = $reqSplit | Select-String "targetName" | Select-Object -Last 1
        }else{
            $tname = $reqSplit | Select-String "targetName" | Select-Object -First 1
        }
    $wlogin       = $reqSplit | Select-String "webLogin"

    $firstName    = $fname.ToString().Split(':')[1].Replace('"','')
    $lastName     = $lname.ToString().Split(':')[1].Replace('"','')
    $onCallMember = "$firstName $lastName"
    $timeZone     = $tzone.ToString().Split(':')[1].Replace('"','')
    $targetName   = $tname.ToString().Split(':')[1].Replace('"','')
    $webLogin     = $wlogin.ToString().Split(':')[1].Replace('"','')
    
    $idItem = $idItem + 1

    if  ($idItem -eq 1){
        ### Write query output 1
        $xMattersQueryOut1 = @{
            Id            = "$idItem";
            onCallMember  = "$onCallMember";
            timeZone      = "$timeZone";
            weblogin      = "$webLogin";
            onCallGroup   = "$targetName"
            }
    
        $xMattersQueryOut1 = $xMattersQueryOut1 | ConvertTo-Json -Depth 100 
        $xMattersQueryOutput1 = $xMattersQueryOut1+","
        }
    else
        {
            ### Write query output 2
            $xMattersQueryOutput2 = @{
            Id            = "$idItem";
            onCallMember  = "$onCallMember";
            timeZone      = "$timeZone";
            weblogin      = "$webLogin";
            onCallGroup   = "$targetName"
            }
        $xMattersQueryOutput2 = $xMattersQueryOutput2 | ConvertTo-Json -Depth 100 
        }
}

$xMattersQueryJoin = "{`r`nmembers:[`r`n"+$xMattersQueryOutput1+$xMattersQueryOutput2+"`r`n]`r`n}"
Write-Host $xMattersQueryJoin | ConvertTo-Json -Depth 100 
