# sharepoint Scope 
$clientID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$clientSecret = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# sharepoint Connect
$SiteURL = 'https://sites.xxxx.com/sites/SREArg'
Connect-PnPOnline -ClientId $clientID -Url $SiteURL -ClientSecret $clientSecret

# show all sharepoint list items

$List = "Oncall"
$ListItems = Get-PnPListItem -List $List
<#
Get-PnPListItem -List "SRE-BigDash-Oncall" -Id '1'
Get-PnPListItem -List "SRE-BigDash-Oncall" -Id '2'
#>
#$ListItems

Set-PnPListItem -List $List -Identity 1 -Values @{"Title" = "Test"; "TimeZone"="ARG"; "Weblogin"="asj32788"; "Status"="Active"}