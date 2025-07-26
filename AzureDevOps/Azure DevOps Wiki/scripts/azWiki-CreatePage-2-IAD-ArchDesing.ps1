$Content = '

[[_TOC_]]


# Attached the Architect diagram

- mostly cover technical architecture and components

e.g
[CUSTOMERNAME_Production Architecture(IAD)](/.attachments/CUSTOMERNAME_Production-IAD-%20Ver.1.0-0c715f52-04ec-4bd1-8984-69ddc359482b.pdf)

'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, '2. IAD - Architecture design')

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
