$Content = '

[[_TOC_]]

## Write down all the runbooks for the alets.
'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, '7. Runbooks')

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