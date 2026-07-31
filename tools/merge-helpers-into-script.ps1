# Merges helper .as classes into a host script as file-private classes.
# FFDec -importScript can only update EXISTING ABC scripts - it cannot add new class names.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\merge-helpers-into-script.ps1
#   (reads patches\manifest.json merge section)
#
# Or with explicit args:
#   -HostScript "com\sulake\habbo\window\HabboWindowManagerComponent.as"
#   -Helpers @("com\sulake\habbo\window\utils\bobba\Foo.as")

param(
    [string]$HostScript = "",
    [string[]]$Helpers = @()
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\config.ps1"

if (-not (Test-Path $SrcScripts)) {
    throw "cleanswf\scripts not found: $SrcScripts"
}

# Load from manifest when args omitted
if (-not $HostScript -or $Helpers.Count -eq 0) {
    if (-not (Test-Path $ManifestPath)) {
        throw "No -HostScript/-Helpers and missing manifest: $ManifestPath"
    }
    $manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $manifest.merge -or -not $manifest.merge.host) {
        Write-Host "manifest.merge empty - nothing to merge."
        exit 0
    }
    $HostScript = $manifest.merge.host
    $Helpers = @($manifest.merge.helpers)
}

if (-not $Helpers -or $Helpers.Count -eq 0) {
    Write-Host "No helpers listed - skip merge."
    exit 0
}

$HwmPath = Join-Path $SrcScripts $HostScript
if (-not (Test-Path $HwmPath)) { throw "Host script not found: $HwmPath" }

$OutRelDir = Split-Path $HostScript -Parent
$OutDir = Join-Path $StagingRoot $OutRelDir
$OutPath = Join-Path $StagingRoot $HostScript

function Convert-ToFilePrivateClass([string]$raw) {
    $m = [regex]::Match($raw, '(?s)package\s+[\w\.]+\s*\{(.*)\}\s*$')
    if (-not $m.Success) { throw "Could not parse package wrapper" }
    $inner = $m.Groups[1].Value
    $imports = [regex]::Matches($inner, '(?m)^\s*import\s+[\w\.\*]+;') | ForEach-Object { $_.Value.Trim() }
    $body = [regex]::Replace($inner, '(?m)^\s*import\s+[\w\.\*]+;\r?\n', '')
    $body = [regex]::Replace($body.Trim(), '^public\s+class\s+', 'class ')
    return @{ Imports = $imports; Body = $body }
}

$hwm = Get-Content -Path $HwmPath -Raw -Encoding UTF8

# Drop package imports that will become same-file helpers
$hwm = $hwm -replace "(?m)^\s*import com\.sulake\.habbo\.window\.utils\.bobba\.\w+;\r?\n", ""
$hwm = $hwm -replace "(?m)^\s*import com\.sulake\.habbo\.window\.utils\.traxmachine\.\w+;\r?\n", ""

$allImports = New-Object System.Collections.Generic.HashSet[string]
$helperBodies = New-Object System.Collections.Generic.List[string]

foreach ($rel in $Helpers) {
    $path = Join-Path $SrcScripts $rel
    if (-not (Test-Path $path)) { throw "Helper not found: $path" }
    $raw = Get-Content -Path $path -Raw -Encoding UTF8
    $converted = Convert-ToFilePrivateClass $raw
    foreach ($imp in $converted.Imports) {
        if ($imp -match 'utils\.(bobba|traxmachine)') { continue }
        [void]$allImports.Add($imp)
    }
    $impText = ($converted.Imports | Where-Object { $_ -notmatch 'utils\.(bobba|traxmachine)' }) -join "`r`n"
    if ($impText) {
        $helperBodies.Add($impText + "`r`n" + $converted.Body)
    } else {
        $helperBodies.Add($converted.Body)
    }
    Write-Host "merged $rel"
}

$pkgImports = ($allImports | Sort-Object | ForEach-Object { "   $_" }) -join "`r`n"
# Insert helper imports before the public class declaration of the host (first match)
if ($pkgImports -and $hwm -match '(?m)^(\s*)public class \w+') {
    $hwm = [regex]::Replace($hwm, '(?m)^(\s*)public class (\w+)', "$pkgImports`r`n`r`n`$1public class `$2", 1)
}

$merged = $hwm.TrimEnd() + "`r`n`r`n" + ($helperBodies -join "`r`n`r`n") + "`r`n"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($OutPath, $merged, $utf8)
Write-Host "Wrote $OutPath ($((Get-Item $OutPath).Length) bytes)"
