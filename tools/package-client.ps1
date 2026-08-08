# Package HabboAir_bobba.swf + brand-pack into dist\airbobba for Bobba Launcher.
# Expects a Habbo.exe-ready AIR tree: either runtime\ already has Habbo.exe + Adobe AIR,
# or -SourceClient points at an existing AirPlus/Habbo install to clone structure from.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\package-client.ps1
#   powershell -ExecutionPolicy Bypass -File tools\package-client.ps1 -SourceClient "D:\path\to\airplus\install"

param(
    [string]$SourceClient = "",
    [string]$Version = "1.1.4"
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\config.ps1"

Write-Host "=== Package AirBobba ==="

if (-not (Test-Path $SwfOut)) {
    throw "Missing $SwfOut - run tools\inject-scripts.ps1 first."
}

# Resolve source of Habbo.exe / AIR runtime bits
$candidates = @()
if ($SourceClient) { $candidates += $SourceClient }
$candidates += @(
    $RuntimeDir,
    (Join-Path $BobbaRoot "..\traxmachine\launcher"),
    (Join-Path $BobbaRoot "..\launcher")
)

$src = $null
foreach ($c in $candidates) {
    $full = [System.IO.Path]::GetFullPath($c)
    if ((Test-Path (Join-Path $full "Habbo.exe")) -or (Test-Path (Join-Path $full "Adobe AIR"))) {
        $src = $full
        break
    }
}

if (-not $src) {
    Write-Warning "No Habbo.exe / Adobe AIR tree found. Packaging SWF + pack only under dist\airbobba."
    Write-Warning "Pass -SourceClient to clone a full AIR client folder."
}

if (Test-Path $DistDir) { Remove-Item $DistDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null

if ($src) {
    Write-Host "Cloning client tree from: $src"
    # Copy structure but skip huge/irrelevant caches if present
    $robolog = Join-Path $env:TEMP "bobba-package-robo.log"
    & robocopy $src $DistDir /E /XD "traxmachine" "local_include\traxmachine" /XF "HabboAir.swf" "HabboAir_trax.swf" /NFL /NDL /NJH /NJS /nc /ns /np
    # robocopy exit codes 0-7 are success-ish
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed with code $LASTEXITCODE" }
}

# Always overwrite with our SWF
Copy-Item $SwfOut (Join-Path $DistDir "HabboAir.swf") -Force
Write-Host "Wrote HabboAir.swf"

# External brand pack
$packName = "bobba"
if (Test-Path $ManifestPath) {
    $m = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($m.packName) { $packName = $m.packName }
}
if (Test-Path $PackSrc) {
    $dstPack = Join-Path $DistDir $packName
    $dstLocal = Join-Path $DistDir "local_include\$packName"
    if (Test-Path $dstPack) { Remove-Item $dstPack -Recurse -Force }
    Copy-Item $PackSrc $dstPack -Recurse -Force
    New-Item -ItemType Directory -Force -Path (Split-Path $dstLocal -Parent) | Out-Null
    if (Test-Path $dstLocal) { Remove-Item $dstLocal -Recurse -Force }
    Copy-Item $PackSrc $dstLocal -Recurse -Force
    Write-Host "Deployed $packName pack"
}

# Trax Machine external pack (catalog + imgs + mp3s)
Deploy-TraxPack $DistDir | Out-Null

# Room placeholders (CDN flash-assets are 404 - AirPlus loads these from local_include/)
$clientAssets = Join-Path $BobbaRoot "client-assets\local_include"
if (Test-Path (Join-Path $clientAssets "PlaceHolderPet.swf")) {
    $dstInclude = Join-Path $DistDir "local_include"
    New-Item -ItemType Directory -Force -Path $dstInclude | Out-Null
    Copy-Item (Join-Path $clientAssets "*.swf") $dstInclude -Force
    Write-Host "Deployed room placeholder SWFs to local_include\"
} else {
    Write-Warning "client-assets\local_include missing - rooms will fail when gordon CDN 404s"
}

# Version stamp for launcher / humans
$meta = @{
    product = "AirBobba"
    name = "Bobba Client"
    version = $Version
    builtAt = (Get-Date).ToString("o")
    swf = "HabboAir.swf"
} | ConvertTo-Json
Set-Content -Path (Join-Path $DistDir "bobba-client.json") -Value $meta -Encoding UTF8
Set-Content -Path (Join-Path $DistDir "VERSION.txt") -Value $Version -NoNewline

Write-Host ""
Write-Host "OK: $DistDir"
Write-Host "    version $Version"
Write-Host "Next: tools\publish-release.ps1 -Version $Version"
Write-Host "      (uploads HabboAir.swf + HabboAirBobbaPatch.zip to GitHub Releases tag latest)"
