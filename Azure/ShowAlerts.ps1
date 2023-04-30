<# Set SRE SPN Context #>
$spnID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$spnKey = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$spnTenantId = "wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"

<# Set Subscription name #>
$mysub = @("wwwwwwwwwwwwwwwwwwwwwww","aaaaaaaaaaaaaaaaaaaa")
$CustomerName = 'eeeeeeeeeeeeeeeeeeee'
$ProductName = 'aaaaaaaaaaaaaaa'

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

function Set-SPNAccount{
    param(
        $spnID,
        $spnKey,
        $spnTenantId
    )
    $password = ConvertTo-SecureString $spnKey -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($spnID, $password)
    Login-AzAccount -ServicePrincipal -Credential $Cred -Tenant $spnTenantId -WarningAction Ignore | Out-Null
}

function Oneliner($object)
{
	$result = [System.String] $object;
	$result = $result -replace "`t|`n|`r",""
	$result = $result -replace " ;|; ",";"
    $result = $result -replace "Â ",""
    $result = $result -replace "`"","'"
	$result = $result -replace [Environment]::NewLine, "";
	$result;
}

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

Set-SPNAccount -spnID $spnID -spnKey $spnKey -spnTenantId $spnTenantId

function GetAlarmRules {
    param(
        [string] $subscriptionName , # name of substring to search 
        [parameter (Mandatory=$true)]
        [string[]] $subsriptionIDs

    )
    try {

        if ($subscriptionName) {
            $subscriptionlist = Get-AzSubscription | Where-Object name -like "*$subscriptionName*" 
        }
        else {
        }
        if (! $subscriptionlist) {throw "subscription list is null"}

        $output1 = @()
        $output2 = @()
        
        foreach ($sub in $subscriptionlist) {
            Set-AzContext -Subscription $($sub.Name) | Out-null

            $rgQueryAlerts = Get-AzScheduledQueryRule -WarningAction Ignore
            $rgMetricAlerts = Get-AzMetricAlertRuleV2 -WarningAction Ignore

          foreach ($sub in $subscriptionlist) {
            Set-AzContext -Subscription $($sub.Name) | Out-null
            $rgQueryAlerts = Get-AzScheduledQueryRule -WarningAction Ignore
            $rgMetricAlerts = Get-AzMetricAlertRuleV2 -WarningAction Ignore

                foreach($metricAlert in $rgMetricAlerts){
                    
                    #if ($metricAlert.Name.ToLower().contains("sre") -and $metricAlert.Name.ToLower().contains("$CustomerName"))
                    #if ($metricAlert.Name.ToLower().contains("sre") -and $logAlert.Name.ToLower().contains("g1by5fvt") -and $logAlert.Name.ToLower().contains("bpf1xkz")) 
                    if ($metricAlert.Name.ToLower().contains("sre")) 
                    {
                    $output1 += [PSCustomObject]@{
                        AlertName = $metricAlert.Name
						Severity = $metricAlert.Severity
						Enabled = $metricAlert.Enabled
						Type = "Metric"
						Description = Oneliner($metricAlert.Description)
                    }        

                }    
                }
                foreach($logAlert in $rgQueryAlerts){
                    
                    #if ($logAlert.Name.ToLower().contains("sre") -and $logAlert.Name.ToLower().contains("$CustomerName")) 
                    #if ($metricAlert.Name.ToLower().contains("sre") -and $logAlert.Name.ToLower().contains("g1by5fvt") -and $logAlert.Name.ToLower().contains("bpf1xkz")) 
                    if ($metricAlert.Name.ToLower().contains("sre")) 
                    {
                    
                    $output2 += [PSCustomObject]@{
                        AlertName = $logAlert.Name
						Severity = $logAlert.Severity
						Enabled= $logAlert.Enabled
						Type = "LogQuery"
						Description = Oneliner($logAlert.Description)
                    }
                    $OutputJson2 = ($output2 + $output1)  | Sort-Object -Property Severity | Where-Object -Property AlertName -match "$ProductName"   #| ConvertTo-Json
                } 
            }
                $OutputMarkdown = $OutputJson2  | Sort-Object -Property @{Expression = "AlertName"; Descending = $true }   | ConvertTo-Markdown               
                $OutputMarkdown2 = $OutputMarkdown | Out-String 

                Write-Output $OutputMarkdown2
        }
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