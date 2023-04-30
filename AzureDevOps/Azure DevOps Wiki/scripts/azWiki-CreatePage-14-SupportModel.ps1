$Content = '

[[_TOC_]]

Support Model for Applications.

 ## Please put the support model of the application here.
'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, '14. Support Model')

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