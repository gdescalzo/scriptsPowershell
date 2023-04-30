<# Set SRE SPN Context #>
$spnID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$spnKey = "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"
$spnTenantId = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyy"

<# Set Subscription name #>
$mysub = @("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
$CustomerName = 'some_customer_name'
$ProductName = 'some_product_name'

<# Wiki Vars #>
$pageId = '11111111'
$PAT = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 
$encodedPAT = "Basic " + [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("`:$PAT"))

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $encodedPAT)
$uri = ('https://dev.azure.com/eysbp/SRE%20-%20Site%20Reliability%20Engineering/_apis/wiki/wikis/SREaaS/pages/{0}?api-version=7.0' -f $pageId)

$response = Invoke-WebRequest $uri -Method 'GET' -Headers $headers
$ETag = $response.Headers.ETag

$headers.Add("If-Match", $ETag)

Function ConvertTo-Markdown {
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [PSObject[]]$collection
    )

    Begin {
        $items = @()
        $columns = @{}
    }

    Process {
        ForEach ($item in $collection) {
            $items += $item

            $item.PSObject.Properties | ForEach-Object {
                if ($null -ne $_.Value ) {
                    if (-not $columns.ContainsKey($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                        $columns[$_.Name] = $_.Value.ToString().Length
                    }
                }
            }
        }
    }

    End {
        ForEach ($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length)
        }

        $header = @()
        ForEach ($key in $columns.Keys) {
            $header += ('{0,-' + $columns[$key] + '}') -f $key
        }
        $header -join ' | '

        $separator = @()
        ForEach ($key in $columns.Keys) {
            $separator += '-' * $columns[$key]
        }
        $separator -join ' | '

        ForEach ($item in $items) {
            $values = @()
            ForEach ($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key) 
            }
            $values -join ' | ' 
        }
    }
}

Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)
    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
    return $authorization
}

function Set-SPNAccount {
    param(
        $spnID,
        $spnKey,
        $spnTenantId
    )
    $password = ConvertTo-SecureString $spnKey -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($spnID, $password)
    Login-AzAccount -ServicePrincipal -Credential $Cred -Tenant $spnTenantId -WarningAction Ignore | Out-Null
}

function Oneliner($object) {
    $result = [System.String] $object;
    $result = $result -replace "`t|`n|`r", ""
    $result = $result -replace " ;|; ", ";"
    $result = $result -replace "Â ", ""
    $result = $result -replace "`"", "'"
    $result = $result -replace [Environment]::NewLine, "";
    $result;
}

Set-SPNAccount -spnID $spnID -spnKey $spnKey -spnTenantId $spnTenantId

function GetAlarmRules {
    param(
        [string] $subscriptionName , # name of substring to search 
        [parameter (Mandatory = $true)]
        [string[]] $subsriptionIDs

    )
    try {

        if ($subscriptionName) {
            $subscriptionlist = Get-AzSubscription | Where-Object name -like "*$subscriptionName*" 
        }
        else {
        }
        if (! $subscriptionlist) { throw "subscription list is null" }

        $output1 = @()
        $output2 = @()
        
        foreach ($sub in $subscriptionlist) {
            Set-AzContext -Subscription $($sub.Name) | Out-null
            $rgQueryAlerts = Get-AzScheduledQueryRule -WarningAction Ignore
            $rgMetricAlerts = Get-AzMetricAlertRuleV2 -WarningAction Ignore

            foreach ($metricAlert in $rgMetricAlerts) {
                    
                if ($metricAlert.Name.ToLower().contains("sre") -and $metricAlert.Name.ToLower().contains("$CustomerName")) {
                    $output1 += [PSCustomObject]@{
                        AlertName = $metricAlert.Name
                        Enabled   = $metricAlert.Enabled
                        Severity  = $metricAlert.Severity
                        Type      = "Metric"
                        Desciption = $metricAlert.Description
                    } 
                }    
            }
            foreach ($logAlert in $rgQueryAlerts) {                    
                if ($logAlert.Name.ToLower().contains("sre") -and $logAlert.Name.ToLower().contains("$CustomerName")) {
                    
                    $output2 += [PSCustomObject]@{
                        AlertName = $logAlert.Name
                        Severity  = $logAlert.Action.Severity
                        Enabled   = $logAlert.Enabled
                        Type      = "LogQuery"
                        Desciption = $logAlert.Description
                    }  
                    $OutputJson2 = ($output2 + $output1) | Sort-Object -Property Severity | Where-Object -Property AlertName -match "$ProductName"     
                } 
            }
            
            $OutputMarkdown = $OutputJson2 | ConvertTo-Markdown
            $OutputMarkdown2 = $OutputMarkdown | Out-String 

            $body = @{
                content = "
[[_TOC_]]

# Document Control

| Document | Description |
|-|-|
| **Version** | 0.1 |
| **Owner** | @<Gaston Descalzo> |
| **Issue Date** | 12/01/23 |

## Version Control

|Version|Author|Issue Date|Changes|
|--|--|--|--|
| 0.1 | @<Gaston Descalzo> | 12/01/23 | Initial version. |

# Alerts

## Alert Rule Identifier

> aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.

| Alert ID | Alert Description |
| - | - |
| xxxxxx | US region |
| aaaaaa | GW region |

## Prod

                
$OutputMarkdown2";
                format = "markdown"
            } | ConvertTo-Json

            #$response = Invoke-RestMethod $uri -Method 'PATCH' -Headers $headers -Body $body -ContentType application/json
            #$response
        }    
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor red
        throw "Error Occured $_"
    }
}

foreach ($i in $mysub) {
    GetAlarmRules -subscriptionName $i -subsriptionIDs 'x'  
}