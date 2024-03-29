$Content = '

[[_TOC_]]

## List down all the Dashbaoed link here.

## **N1 SLO**

https://bigeye.sbp.eyclienthub.com/d/axCu7UWGk/n1-slo?orgId=110

## **N2 Performance**

https://bigeye.sbp.eyclienthub.com/d/WHHuYhznz/n2-performance?orgId=110

## **N3 Infrastructure**
- **API Management**  
https://bigeye.sbp.eyclienthub.com/d/-rfNCFznz/n3-api-management?orgId=110
- **Application Gateway**  
https://bigeye.sbp.eyclienthub.com/d/sB2bebk7k/n3-applicationgateway?orgId=110
- **Event Hub**  
https://bigeye.sbp.eyclienthub.com/d/hbWPWck7k/n3-eventhub?orgId=110
- **Key Vault**  
https://bigeye.sbp.eyclienthub.com/d/DfiSU1QMk/n3-key-vaults?orgId=110
- **SQL Database**  
https://bigeye.sbp.eyclienthub.com/d/NJc7CFz7z/n3-sql-database?orgId=110
- **Storage Account**  
https://bigeye.sbp.eyclienthub.com/d/M8LSzMknk/n3-storageaccount?orgId=110
- **Traffic Manager**  
https://bigeye.sbp.eyclienthub.com/d/oc4-61QMk/n3-traffic-manager?orgId=110
'


# Create WIKI page
$uri = ('https://dev.azure.com/{0}/{1}/_apis/wiki/wikis/{2}/pages?path={3}&api-version=5.0' -f $OrganizationName, $ProjectName, $WikiName, '5. Dashboards')

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