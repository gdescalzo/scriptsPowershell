# Scope
$clientID = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$clientSecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx="

# Theme
$webUrl = 'https://sites.xxxxxxxxxxx.com/sites/xxxxxxxxxxxxx'
$headerLayout = "Compact" # Standard or Compact
$headerEmphasis = "Strong"  # None, Neutral, Soft or Strong
$themeName = "xxxxxxxxxxxxxxx"

# Connect
Connect-PnPOnline -ClientId $clientID -Url $webUrl -ClientSecret $clientSecret

Set-PnPWebTheme -Theme $themeName
$web = Get-PnPWeb
$web.HeaderLayout = $headerLayout
$web.HeaderEmphasis = $headerEmphasis
$web.Update()
Invoke-PnPQuery