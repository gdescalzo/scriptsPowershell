$Content = '

[[_TOC_]]

## List down back up details.
'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, '12. Backups')

$Header = @{
    'Authorization' = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")) 
}

$params = @{
    'Uri'         = $uri
    'Headers'     = $Header
    'Method'      = 'Put'
    'ContentType' = 'application/json; charset=utf-8'
    'body'        = @{content = $content; } | ConvertTo-Json
}

Invoke-RestMethod @params