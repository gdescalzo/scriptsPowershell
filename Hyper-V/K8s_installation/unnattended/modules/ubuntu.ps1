<# Import Variables #>
$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent                   # Detect project root
$VarsPath = Join-Path $ProjectRoot 'vars\vars.ps1'                      # Build path to vars.ps1
. $VarsPath

<# Download Ubuntu Server 22.04 live-server ISO #>
function Ubuntu-ISO-Download {
    [CmdletBinding()]
    param ()

    $tempPath   = Get-HostTempPath
    $baseUrl    = $ubuntu_BaseURL
    $pattern    = $ubuntu_ISOpattern

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

<# Create cloud-init ISO #>
function New-CloudInitISO {
    # Generate an ISO with meta-data.yml and user-data.yml for cloud-init
    param(
        [string]$CloudInitDir = (Join-Path $PSScriptRoot "..\cloud-init"), # autodetecta carpeta
        [string]$OutputISO = $(Join-Path (Get-HostTempPath) "cloudinit.iso")
    )

    # Check for the existence of .yml files
    $metaDataFile = Join-Path $CloudInitDir "meta-data.yml"
    $userDataFile = Join-Path $CloudInitDir "user-data.yml"

    if (-not (Test-Path $metaDataFile)) {
        Write-Error "❌ $metaDataFile not found"
        return $null
    }
    if (-not (Test-Path $userDataFile)) {
        Write-Error "❌ $userDataFile not found"
        return $null
    }

    # Create a temporary folder for staging
    $isoFolder = Join-Path (Get-HostTempPath) "cloudinit_staging"
    if (Test-Path $isoFolder) {
        Remove-Item $isoFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $isoFolder | Out-Null

    # Copy files as meta-data and user-data (without extension)
    Copy-Item -Path $metaDataFile -Destination (Join-Path $isoFolder "meta-data")
    Copy-Item -Path $userDataFile -Destination (Join-Path $isoFolder "user-data")

    # Localizar oscdimg.exe
    $oscdimg = Get-OscdimgPath
    if (-not $oscdimg) {
        Write-Error "❌ oscdimg.exe was not found. Please install 'Deployment Tools' from the Windows ADK."
        return $null
    }

    # Generate ISO
    Write-Host "🔄 Creating ISO with cloud-init in: $OutputISO"
    $arguments = @("-n", "-m", $isoFolder, $OutputISO)
    Start-Process -FilePath $oscdimg -ArgumentList $arguments -Wait -NoNewWindow

    if (Test-Path $OutputISO) {
        Write-Host "✅ ISO generated correctly: $OutputISO"
        return $OutputISO
    }
    else {
        Write-Error "❌ ISO generation failed."
        return $null
    }
}
