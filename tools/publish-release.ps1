# Build and publish HabboAir.swf + HabboAirBobbaPatch.zip to GitHub Releases.
# Mirrors AirPlus: tag `latest` is the launcher download URL; also tags vX.Y.Z.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\publish-release.ps1
#   powershell -ExecutionPolicy Bypass -File tools\publish-release.ps1 -Version 0.1.1-alpha
#
# Requires: HabboAir_bobba.swf (run inject first), gh auth, network for AirPlus patch base.

param(
    [string]$Version = "0.1.0-alpha",
    [switch]$SkipUpload
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\config.ps1"

if (-not (Test-Path $SwfOut)) {
    throw "Missing $SwfOut - run tools\inject-scripts.ps1 first."
}

$outDir = Join-Path $BobbaRoot "dist\release"
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$swfAsset = Join-Path $outDir "HabboAir.swf"
Copy-Item $SwfOut $swfAsset -Force
Write-Host "SWF asset: $swfAsset"

# Patch build dir = AirPlus patch base + Bobba brand + placeholders
$patchRoot = Join-Path $env:TEMP ("habboairbobba-patch-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $patchRoot | Out-Null
try {
    $airplusZip = Join-Path $env:TEMP "HabboAirPlusPatch.zip"
    if (-not (Test-Path $airplusZip)) {
        $url = "https://raw.githubusercontent.com/LilithRainbows/HabboCustomLauncher/main/Assets/HabboAirPlusPatch.zip"
        Write-Host "Downloading AirPlus patch base..."
        Invoke-WebRequest -Uri $url -OutFile $airplusZip -UseBasicParsing
    }
    Expand-Archive -Path $airplusZip -DestinationPath $patchRoot -Force

    $placeholders = Join-Path $BobbaRoot "client-assets\local_include"
    if (Test-Path (Join-Path $placeholders "PlaceHolderPet.swf")) {
        Copy-Item (Join-Path $placeholders "*.swf") (Join-Path $patchRoot "local_include") -Force
    } else {
        Write-Warning "client-assets\local_include missing placeholders"
    }

    if (-not (Test-Path $PackSrc)) { throw "Missing brand-pack at $PackSrc" }
    $bobba = Join-Path $patchRoot "bobba"
    $bobbaLocal = Join-Path $patchRoot "local_include\bobba"
    if (Test-Path $bobba) { Remove-Item $bobba -Recurse -Force }
    if (Test-Path $bobbaLocal) { Remove-Item $bobbaLocal -Recurse -Force }
    Copy-Item $PackSrc $bobba -Recurse -Force
    New-Item -ItemType Directory -Force -Path (Split-Path $bobbaLocal -Parent) | Out-Null
    Copy-Item $PackSrc $bobbaLocal -Recurse -Force

    $meta = @{
        product = "AirBobba"
        name = "Bobba Client"
        version = $Version
        builtAt = (Get-Date).ToString("o")
        swf = "HabboAir.swf"
    } | ConvertTo-Json
    Set-Content -Path (Join-Path $patchRoot "bobba-client.json") -Value $meta -Encoding UTF8
    Set-Content -Path (Join-Path $outDir "VERSION.txt") -Value $Version -NoNewline

    $patchZip = Join-Path $outDir "HabboAirBobbaPatch.zip"
    # Prefer Python for forward-slash zip paths (Compress-Archive uses backslashes)
    $py = @"
import zipfile, pathlib
src = pathlib.Path(r'$patchRoot')
out = pathlib.Path(r'$patchZip')
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for p in sorted(src.rglob('*')):
        if p.is_file():
            z.write(p, p.relative_to(src).as_posix())
print(out)
"@
    python -c $py
    if ($LASTEXITCODE -ne 0) { throw "Failed to build HabboAirBobbaPatch.zip" }
    Write-Host "Patch asset: $patchZip"
}
finally {
    if (Test-Path $patchRoot) { Remove-Item $patchRoot -Recurse -Force }
}

if ($SkipUpload) {
    Write-Host "SkipUpload set — assets ready under $outDir"
    exit 0
}

$notes = @"
## Bobba Client $Version

Injected HabboAirPlus SWF + external brand pack / room placeholders.

Launcher downloads ``HabboAir.swf`` + ``HabboAirBobbaPatch.zip`` from the ``latest`` tag.
Install: ``%AppData%\packet.bobba.launcher\downloads\airbobba\{version}\``
"@

$assets = @($swfAsset, $patchZip)
$tagVersion = if ($Version.StartsWith("v")) { $Version } else { "v$Version" }

function Publish-ReleaseTag([string]$Tag, [string]$Title, [bool]$AsLatest) {
    $exists = $false
    gh release view $Tag -R Bobba-Packet/HabboAirBobba 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $exists = $true }
    if ($exists) {
        Write-Host "Updating assets on existing release $Tag..."
        gh release upload $Tag @assets -R Bobba-Packet/HabboAirBobba --clobber
    } else {
        $latestFlag = if ($AsLatest) { @() } else { @("--latest=false") }
        gh release create $Tag -R Bobba-Packet/HabboAirBobba --title $Title --notes $notes @latestFlag @assets
    }
}

Publish-ReleaseTag -Tag "latest" -Title "Bobba Client (latest)" -AsLatest $true
Publish-ReleaseTag -Tag $tagVersion -Title "Bobba Client $Version" -AsLatest $false

Write-Host ""
Write-Host "OK: https://github.com/Bobba-Packet/HabboAirBobba/releases/tag/latest"
Write-Host "    https://github.com/Bobba-Packet/HabboAirBobba/releases/tag/$tagVersion"
Write-Host "NOTE: repo must be public (or assets mirrored) for the launcher to download anonymously."
