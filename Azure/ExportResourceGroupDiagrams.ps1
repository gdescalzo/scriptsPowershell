<# Required 
install-module -name AzViz
install-module -name Az
Please download and install from: https://graphviz.org/download/ "graphviz" package for your platform.
#>

<# Set SRE SPN Context #>
$spnID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$spnKey = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$spnTenantId = "wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"

<# Set Subscription name #>
$mysub = @("ddddddddddddddddddddddddddddddddddddddd")
$myrg = @("22222222222", "333333333333", "4444444444444444", "55555555555", "666666666666666666666")

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

Set-SPNAccount -spnID $spnID -spnKey $spnKey -spnTenantId $spnTenantId

Import-Module AzViz

function AzExportRGdiagrams {
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
        
        foreach ($sub in $subscriptionlist) {
            Set-AzContext -Subscription $($sub.Name) | Out-null

            foreach ($resoruceGroup in $myrg) {
                Export-AzViz -ResourceGroup $resoruceGroup -Theme dark -OutputFormat png -show -OutputFilePath c:\ -LabelVerbosity 1 -CategoryDepth 1

            }
		}
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor red
        throw "Error Occured $_"
    }
}

foreach ($i in $mysub) {
    AzExportRGdiagrams -subscriptionName $i -subsriptionIDs 'x'  
   }