<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Download Ubuntu Server 22.04 live-server ISO #>
function Ubuntu-ISO-Download {
    [CmdletBinding()]
    param ()

    $tempPath = $HostTempPath
    $baseUrl = $ubuntu_BaseURL
    $pattern = $ubuntu_ISOpattern

    try {
        Write-Host "🔎 Fetching Ubuntu release page..."
        $html = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing

        # Filter valid hrefs and apply regex
        $isoRelativePath = ($html.Links |
            Where-Object { $_.href -and ($_).href -is [string] } |
            Where-Object { $_.href -match $pattern } |
            Select-Object -First 1
        ).href

        if (-not $isoRelativePath) {
            Write-Error "❌ No valid ISO file found on the release page."
            exit 1
        }

        # CConstruct absolute URL
        if ($isoRelativePath -like "http*") {
            $isoUrl = $isoRelativePath
        }
        else {
            $isoUrl = "$baseUrl$isoRelativePath"
        }

        $isoFilename = Split-Path -Leaf $isoRelativePath
        $isoPath = Join-Path $tempPath $isoFilename

        # Download only if it does not exist
        if (-not (Test-Path $isoPath)) {
            Write-Host "⬇️ Downloading ISO from: $isoUrl"
            Invoke-WebRequest -Uri $isoUrl -OutFile $isoPath
            Write-Host "✅ Download completed: $isoPath"
        }
        else {
            Write-Host "✅ ISO already exists at: $isoPath"
        }

        return $isoPath
    }
    catch {
        Write-Error "❌ Error while downloading ISO: $_"
        exit 1
    }
}