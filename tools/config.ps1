# Shared paths for HabboAirBobba tools.
# Dot-source from other scripts: . "$PSScriptRoot\config.ps1"

$ErrorActionPreference = "Stop"

$Script:BobbaRoot = Split-Path -Parent $PSScriptRoot
if (-not $Script:BobbaRoot) { $Script:BobbaRoot = (Get-Location).Path }

function Resolve-FfdecCli {
    $candidates = @(
        (Join-Path $BobbaRoot "ffdec\ffdec-cli.exe"),
        (Join-Path $BobbaRoot "..\traxmachine\ffdec\ffdec-cli.exe"),
        (Join-Path $PSScriptRoot "ffdec\ffdec-cli.exe")
    )
    if ($env:FFDEC_CLI) { $candidates = @($env:FFDEC_CLI) + $candidates }
    foreach ($c in $candidates) {
        $full = [System.IO.Path]::GetFullPath($c)
        if (Test-Path $full) { return $full }
    }
    return $null
}

function Resolve-AirSdkHome {
    if ($env:AIR_SDK_HOME -and (Test-Path (Join-Path $env:AIR_SDK_HOME "bin\adl.exe"))) {
        return $env:AIR_SDK_HOME
    }
    $candidates = @(
        "D:\SDKs\AIR\AIRSDK_51.2.2",
        "D:\SDKs\AIR\AIRSDK_51.3.1.2",
        "C:\AIRSDK"
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c "bin\adl.exe")) { return $c }
    }
    return $null
}

$Script:FfdecCli = Resolve-FfdecCli
$Script:AirSdkHome = Resolve-AirSdkHome
$Script:SwfIn = Join-Path $BobbaRoot "HabboAir.swf"
$Script:SwfOut = Join-Path $BobbaRoot "HabboAir_bobba.swf"
$Script:SrcScripts = Join-Path $BobbaRoot "cleanswf\scripts"
$Script:StagingRoot = Join-Path $BobbaRoot "tools\inject-staging\scripts"
$Script:PackSrc = Join-Path $BobbaRoot "brand-pack"
$Script:RuntimeDir = Join-Path $BobbaRoot "runtime"
$Script:DistDir = Join-Path $BobbaRoot "dist\airbobba"
$Script:ManifestPath = Join-Path $BobbaRoot "patches\manifest.json"
$Script:InjectLog = Join-Path $BobbaRoot "tools\inject-log.txt"
$Script:DebugDescriptor = Join-Path $PSScriptRoot "HabboAir-debug-app.xml"

function Resolve-TraxPackSrc {
    $candidates = @(
        (Join-Path $BobbaRoot "traxmachine-pack"),
        (Join-Path $BobbaRoot "..\traxmachine\traxmachine-pack")
    )
    foreach ($c in $candidates) {
        $full = [System.IO.Path]::GetFullPath($c)
        if (Test-Path (Join-Path $full "catalog.json")) { return $full }
    }
    return $null
}

function Deploy-TraxPack([string]$TargetRoot) {
    $src = Resolve-TraxPackSrc
    if (-not $src) {
        Write-Warning "traxmachine-pack missing (looked in repo + ..\traxmachine) - Trax Machine assets will not load"
        return $false
    }
    $targets = @(
        (Join-Path $TargetRoot "traxmachine"),
        (Join-Path $TargetRoot "local_include\traxmachine")
    )
    foreach ($dst in $targets) {
        $parent = Split-Path $dst -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $src $dst -Recurse -Force
        Write-Host "Deployed traxmachine-pack -> $dst"
    }
    return $true
}

$Script:TraxPackSrc = Resolve-TraxPackSrc
