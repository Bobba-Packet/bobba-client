# Inject Bobba AS3 patches into HabboAir.swf via FFDec -importScript.
# Adapted from traxmachine/tools/inject-traxmachine.ps1.
#
# FFDec CLI cannot ADD new classes - helpers listed in patches/manifest.json
# are merged into a host script as file-private classes first.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\inject-scripts.ps1

$ErrorActionPreference = "Continue"
. "$PSScriptRoot\config.ps1"

Write-Host "=== HabboAirBobba inject ==="
Write-Host "Root: $BobbaRoot"

if (-not $FfdecCli) { throw "ffdec-cli not found. Set FFDEC_CLI or place ffdec under repo / sibling traxmachine." }
if (-not (Test-Path $SwfIn)) { throw "HabboAir.swf not found: $SwfIn - drop the pinned AirPlus baseline at repo root." }
if (-not (Test-Path $ManifestPath)) { throw "Missing patches\manifest.json" }

$manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

# Backup (keep only the 3 most recent HabboAir.swf.bak_* copies)
$Backup = Join-Path $BobbaRoot ("HabboAir.swf.bak_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
Copy-Item $SwfIn $Backup -Force
Write-Host "Backup: $Backup"
Get-ChildItem -Path $BobbaRoot -File -Filter "HabboAir.swf.bak*" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip 3 |
    ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "Pruned old backup: $($_.Name)"
    }

# Deploy external brand pack (same dual-path pattern as Traxmachine)
$packName = if ($manifest.packName) { $manifest.packName } else { "bobba" }
if (Test-Path $PackSrc) {
    $targets = @(
        (Join-Path $BobbaRoot $packName),
        (Join-Path $BobbaRoot "local_include\$packName")
    )
    foreach ($PackDst in $targets) {
        $parent = Split-Path $PackDst -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        if (Test-Path $PackDst) { Remove-Item $PackDst -Recurse -Force }
        Copy-Item $PackSrc $PackDst -Recurse -Force
        Write-Host "Deployed brand-pack -> $PackDst"
    }
} else {
    Write-Warning "brand-pack missing (optional for first inject)"
}

# Merge helpers into host (if configured)
$mergeScript = Join-Path $PSScriptRoot "merge-helpers-into-script.ps1"
Write-Host "Merging helpers (if any)..."
& powershell -ExecutionPolicy Bypass -File $mergeScript
if ($LASTEXITCODE -ne 0) { throw "merge-helpers-into-script.ps1 failed" }

# Fresh staging, but keep the merged host if merge wrote it (same as Trax)
$mergedHostRel = $null
if ($manifest.merge -and $manifest.merge.host) {
    $mergedHostRel = [string]$manifest.merge.host
}
$mergedHostPath = if ($mergedHostRel) { Join-Path $StagingRoot $mergedHostRel } else { $null }
$mergedHostBackup = $null
if ($mergedHostPath -and (Test-Path $mergedHostPath)) {
    $mergedHostBackup = Join-Path $env:TEMP ("habboairbobba_merged_host_" + [guid]::NewGuid().ToString("N") + ".as")
    Copy-Item $mergedHostPath $mergedHostBackup -Force
    Write-Host "Preserved merged host: $mergedHostRel"
}
if (Test-Path $StagingRoot) {
    Remove-Item $StagingRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $StagingRoot | Out-Null
if ($mergedHostBackup -and (Test-Path $mergedHostBackup)) {
    $restoreDir = Split-Path (Join-Path $StagingRoot $mergedHostRel) -Parent
    New-Item -ItemType Directory -Force -Path $restoreDir | Out-Null
    Copy-Item $mergedHostBackup (Join-Path $StagingRoot $mergedHostRel) -Force
    Remove-Item $mergedHostBackup -Force
}

# Stage scripts listed in manifest
$stageList = @($manifest.stage)
if (-not $stageList -or $stageList.Count -eq 0) {
    throw "patches\manifest.json has empty stage[] - nothing to inject."
}

foreach ($rel in $stageList) {
    $src = Join-Path $SrcScripts $rel
    # Merged host may already be in staging
    $dst = Join-Path $StagingRoot $rel
    $dstDir = Split-Path $dst -Parent
    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null

    if ($mergedHostRel -and ($rel -eq $mergedHostRel) -and (Test-Path $dst)) {
        Write-Host "staged (merged) $rel"
        continue
    }
    if (-not (Test-Path $src)) {
        Write-Warning "skip missing: $rel"
        continue
    }
    Copy-Item $src $dst -Force
    Write-Host "staged $rel"
}

# Ensure merged host is present if merge ran
if ($manifest.merge -and $manifest.merge.host) {
    $mergedPath = Join-Path $StagingRoot $manifest.merge.host
    if (-not (Test-Path $mergedPath)) {
        Write-Warning "Expected merged host missing: $($manifest.merge.host)"
    }
}

Write-Host "Staged:"
Get-ChildItem $StagingRoot -Recurse -Filter "*.as" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host " - $($_.FullName.Substring($StagingRoot.Length + 1))"
}

if (Test-Path $SwfOut) { Remove-Item $SwfOut -Force }

Write-Host "Importing with FFDec (-air -onerror ignore)..."
Write-Host "  CLI: $FfdecCli"
cmd /c "`"$FfdecCli`" -air -onerror ignore -importScript `"$SwfIn`" `"$SwfOut`" `"$StagingRoot`" > `"$InjectLog`" 2>&1"
$code = $LASTEXITCODE
Write-Host "FFDec exit code: $code"
Get-Content $InjectLog -Tail 40 -ErrorAction SilentlyContinue

if (-not (Test-Path $SwfOut)) {
    Write-Host ""
    Write-Host "FAILED: HabboAir_bobba.swf was not created. See $InjectLog"
    exit 1
}

$size = (Get-Item $SwfOut).Length
$orig = (Get-Item $SwfIn).Length
Write-Host ""
Write-Host "OK: $SwfOut"
Write-Host "    size $size bytes (original $orig, delta $($size - $orig))"
Write-Host ""
Write-Host "Next:"
Write-Host "  1) tools\update-and-debug.bat   (ADL smoke test)"
Write-Host "  2) tools\package-client.ps1     (dist\airbobba for launcher)"
Write-Host "  3) Keep folder $packName\ next to the SWF at install time"
