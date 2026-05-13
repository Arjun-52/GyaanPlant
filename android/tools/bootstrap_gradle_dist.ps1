# Downloads the Gradle distribution using Windows TLS (Invoke-WebRequest), then places the zip in the
# same cache folder Gradle wrapper uses (MD5(URL UTF-8) as BigInteger, rendered base-36 — matches
# org.gradle.wrapper.PathAssembler). Use when `gradlew` fails with PKIX / SSLHandshakeException.

param(
    [string]$AndroidRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"

function Get-DistributionUrlFromProperties {
    param([string]$PropsPath)
    $raw = Get-Content -LiteralPath $PropsPath -Raw
    if ($raw -notmatch "(?m)^distributionUrl=(.+)$") {
        throw "distributionUrl not found in $PropsPath"
    }
    $value = $Matches[1].Trim()
    # Properties escape ':' and '/' with backslash (Gradle wrapper format).
    return $value.Replace('\:', ':').Replace('\/', '/')
}

function Get-GradleWrapperFolderName {
    param([string]$Url)
    $md5 = [System.Security.Cryptography.MD5]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($Url))
    $hex = [BitConverter]::ToString($md5).Replace("-", "").ToLowerInvariant()
    $n = [System.Numerics.BigInteger]::Parse(
        "00" + $hex,
        [System.Globalization.NumberStyles]::AllowHexSpecifier)
    $chars = "0123456789abcdefghijklmnopqrstuvwxyz"
    $s = ""
    while ($n -gt 0) {
        $rem = [int][System.Numerics.BigInteger]::Remainder($n, 36)
        $n = [System.Numerics.BigInteger]::Divide($n, 36)
        $s = $chars[$rem] + $s
    }
    if ($s -eq "") { return "0" }
    return $s
}

$props = Join-Path $AndroidRoot "gradle\wrapper\gradle-wrapper.properties"
$url = Get-DistributionUrlFromProperties -PropsPath $props
$uri = [Uri]$url
$zipName = [System.IO.Path]::GetFileName($uri.LocalPath)
$distDirName = [System.IO.Path]::GetFileNameWithoutExtension($zipName)

$folderHash = Get-GradleWrapperFolderName -Url $url
$destRoot = Join-Path $env:USERPROFILE ".gradle\wrapper\dists\$distDirName\$folderHash"
New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

$zipPath = Join-Path $destRoot $zipName

Write-Host "distributionUrl: $url"
Write-Host "cache dir:       $destRoot"

if ((Test-Path $zipPath) -and ((Get-Item $zipPath).Length -gt 1MB)) {
    Write-Host "Zip already present: $zipPath"
    exit 0
}

Write-Host "Downloading $zipName ..."
$maxAttempts = 5
for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
        break
    } catch {
        Write-Warning "Attempt $i failed: $($_.Exception.Message)"
        if ($i -eq $maxAttempts) { throw }
        Start-Sleep -Seconds ($i * 3)
    }
}

if (-not (Test-Path $zipPath)) {
    throw "Download failed: $zipPath"
}

$lines = Get-Content -LiteralPath $props | Where-Object { $_ -match "^distributionSha256Sum=" }
if ($lines) {
    $expected = ($lines[0] -split "=", 2)[1].Trim().ToLowerInvariant()
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath
    $actual = $hash.Hash.ToLowerInvariant()
    if ($actual -ne $expected) {
        Remove-Item -Force $zipPath
        throw "SHA256 mismatch. Expected $expected got $actual"
    }
    Write-Host "SHA256 verified."
}

Write-Host "Done. Run gradlew.bat or flutter build again."
