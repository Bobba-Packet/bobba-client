# Getting started

[← Back to README](../README.md)

## Requirements

| Need | Notes |
|---|---|
| **Java** | Required by FFDec |
| **FFDec CLI** | Put it at `ffdec\ffdec-cli.exe`, or set `FFDEC_CLI` to the executable |
| **AIR SDK** | Defaults to `D:\SDKs\AIR\AIRSDK_51.2.2`; override with `AIR_SDK_HOME` |
| **`HabboAir.swf`** | The pinned upstream AirPlus baseline, at the repo root (gitignored) |
| **`cleanswf\scripts\`** | Full AS3 export of that SWF (see below) |
| **Python** | Only for `publish-release.ps1` (zip with forward-slash paths) and the atlas exporter |
| **GitHub CLI (`gh`)** | Only for publishing releases |

All paths are resolved in `tools/config.ps1` — that is the one file to edit if your SDK or FFDec lives somewhere else.

## The decompiled tree

To produce `cleanswf\scripts\`, open the baseline `HabboAir.swf` in the FFDec GUI and export **Scripts** into that folder. The export is ~8600 files and is gitignored except for `Logger.as` and the helpers under `utils/bobba/` and `utils/traxmachine/`, which are the only Bobba-owned sources in git.

Never re-export over an existing tree. Everything else we edit — `LilithCustoms.as`, `HabboWindowManagerComponent.as`, `HabboLoadingScreen.as`, the `login/` and `splash/` screens — lives only on disk, so a full re-export silently destroys those changes and `git checkout` cannot bring them back. Export to a temp folder and copy in just the files you need.

## Repo layout

```
README.md               index
docs/                   this documentation
tools/                  inject, merge, debug, package, publish, layout tweakers
patches/manifest.json   which scripts get staged and merged
cleanswf/scripts/       decompiled AS3 — edit here
brand-pack/             runtime images (deployed next to the SWF)
client-assets/          room placeholder SWFs, atlas slices, brand PNG sources
runtime/                ADL app directory (debug target, generated)
dist/                   packaged client + release assets (generated)
HabboAir.swf            upstream baseline (gitignored)
HabboAir_bobba.swf      inject output (gitignored)
```

`bobba/`, `local_include/` and `traxmachine/` at the root are deployed copies written by the tooling; never edit them by hand.

## Run it (edit → inject → debug)

```powershell
powershell -ExecutionPolicy Bypass -File tools\inject-scripts.ps1
tools\update-and-debug.bat
```

`inject-scripts.ps1` backs up the baseline (keeping the last three `.bak_*`), deploys `brand-pack/` and the Trax pack, merges helper classes into their host script, stages everything listed in `patches/manifest.json`, and runs `ffdec-cli -air -onerror ignore -importScript` to produce `HabboAir_bobba.swf`. Watch the reported size delta: **delta 0 means nothing was injected**, even though FFDec exits cleanly.

`update-and-debug.bat` copies that SWF into `runtime/`, syncs the packs and placeholder SWFs, and launches it under `adl.exe` with `tools/HabboAir-debug-app.xml`. Stack traces appear in the console; `ExternalInterface is not available` under ADL is normal.

Editing only images in `brand-pack/`? Re-run `update-and-debug.bat` on its own — the sync step picks them up without a new inject.

Next: [Editing ActionScript](editing-actionscript.md) · [Assets](assets.md) · [Troubleshooting](troubleshooting.md)
