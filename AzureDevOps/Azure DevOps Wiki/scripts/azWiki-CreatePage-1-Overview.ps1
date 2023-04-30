$Content = '

[[_TOC_]]

#Application Overview

## Why is the Application Require?
example

EY FUSE is a platform that enables third party financial service providers to securely access consumer banking, transaction, and other financial data in line with the ACCCs(Australian Competition and Consumer Commission) requirements by supporting their consumers in managing consent and to meet CDR(Consumer data right) compliance requirements.

## What the application does?

example

Provides the following features:

- It provides a customized user interface for each client according to the bank standards.

- The data recipient bank can request for a consent to desired data holder bank from which data is to be extracted.

- Here the application provides mainly the consent dashboards to view the details on the provided consents.

## Who are the users of the application

e.g
- Users of this application are both data holder and data recipients bank who are accredited by ACCC, OAIC standards. 

## How the users interact with the application

e.g
- They interact with the application through EY Fuse User Interfaces which is customized to the client bank.


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