## xMatters 
$URL_ARG = "https://xxxxxxx.xmatters.com/api/xm/1/on-call?groups=xxxxxxxxxxxxxxxxxxxxxxxxxx&membersPerShift=1"
$URL_INDIA = "https://ey.xmatters.com/api/xm/1/on-call?groups=xxxxxxxxxxxxxxxxxxxxxxxxxx&membersPerShift=1"

$user = 'x-api-key-6153b520-878b-49e9-81e7-e0843a221d14'
$pass = ConvertTo-SecureString 'dcdba3e0-31a8-400f-abb7-c40737825e33' -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass

$req      = Invoke-WebRequest -Credential $cred -Uri $URL_ARG -Verbose -ContentType application/json -Method Get -UseBasicParsing | Select-Object -Expand Content
$reqSplit = $req -split "," | sort
$fname    = $reqSplit | Select-String "firstName" 
$lname    = $reqSplit | Select-String "lastName"
$tzone    = $reqSplit | Select-String "timezone"
$tname    = $reqSplit | Select-String "targetName" | Select-Object -First 1
$wlogin   = $reqSplit | Select-String "webLogin"
 
$firstName    = $fname.ToString().Split(':')[1].Replace('"','')
$lastName     = $lname.ToString().Split(':')[1].Replace('"','')
$onCallMember = "$firstName $lastName"
$timeZone     = $tzone.ToString().Split(':')[1].Replace('"','')
$targetName   = $tname.ToString().Split(':')[1].Replace('"','')
$webLogin     = $wlogin.ToString().Split(':')[1].Replace('"','')

## SharePoint 
$clientID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$clientSecret = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

$SiteURL = 'https://sites.xxxxxxxx.com/sites/xxxxxxxx'
$List = "Oncall"

Connect-PnPOnline -ClientId $clientID -Url $SiteURL -ClientSecret $clientSecret
Set-PnPListItem -List $List -Identity 1 -Values @{"Title" = "$onCallMember"; "TimeZone"="$timeZone"; "Weblogin"="$webLogin"; "Status"="$targetName"}


