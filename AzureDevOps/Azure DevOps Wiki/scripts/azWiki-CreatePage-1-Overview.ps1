$Content = '

[[_TOC_]]

#Application Overview

## Why is the Application Required?
example

Some application overview. Who is the customer?

## What does the application do?

example

Describe the user journey

## How the users interact with the application

e.g
- They interact with the application through EY Fuse User Interfaces, which are customized to the client bank.

'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, '1. Overview')

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
