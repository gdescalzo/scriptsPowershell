function Get-IsoLinks {
    try {
        $url = "http://isoredirect.centos.org/centos/8/isos/x86_64/"
        $response = Invoke-WebRequest $url
        $links = $response.Links | Where-Object href -like "*isos/x86_64/*"

        foreach ($link in $links) {
            $urls = $link.href
            Write-Output $urls
        }
    }
    catch {
        Write-Error "Error scraping ISO links: $_.Exception.Message"
    }
}
function Test-Url {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head
        if ($response.StatusCode -eq 200) {
            Write-Output "$Url is working"
        }
        else {
            Write-Output "$Url is not working"
        }
    }
    catch {
        Write-Output "$Url is not working: $_.Exception.Message"
    }
}

Get-IsoLinks | ForEach-Object {
    Test-Url $_
}

