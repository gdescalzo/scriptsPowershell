<#
    PowerShell script to create Azure DevOps WIKI Markdown Documentation

    https://docs.microsoft.com/en-US/rest/api/azure/devops/wiki/pages/create%20or%20update?view=azure-devops-rest-5.0#examples
    https://medium.com/digikare/create-automatic-release-notes-on-azuredevops-f235376ec533

    Requirements:
    - PSDocs PowerShell Module (Install-Module -Name PSDocs)
#>

# Import Module
Import-Module -Name PSDocs;

#Azure Setings
$OrganizationName = 'murdok2022'
$ProjectName = 'GD-Automation'
$PAT = 'o4t7ovfeudluki2mkbactveci4tavvswqlxi4vqwfpx5zkvbd5sa'
$WikiName = 'GD-Automation.wiki'

# Generate markdown for the inline document
$options = New-PSDocumentOption -Option @{ 'Markdown.UseEdgePipes' = 'Always'; 'Markdown.ColumnPadding' = 'None' };
$null = [PSDocs.Configuration.PSDocumentOption]$Options
$InputObject = Get-Service | Select-Object -First 5
$Content = '# This is a test for content automation

- section 1
- section 2
- section 3
'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, 'demopage2')

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