# Package and release

[← Back to README](../README.md)

```powershell
powershell -ExecutionPolicy Bypass -File tools\package-client.ps1 -Version 0.1.5-alpha
powershell -ExecutionPolicy Bypass -File tools\publish-release.ps1 -Version 0.1.5-alpha
```

Both scripts need `HabboAir_bobba.swf`, so run the inject first — see [Getting started](getting-started.md#run-it-edit--inject--debug).

## Packaging

`package-client.ps1` builds a runnable client in `dist\airbobba\`: it clones an AIR tree that has `Habbo.exe` and `Adobe AIR` (from `runtime/`, or pass `-SourceClient <path>`), overwrites the SWF, deploys all packs and placeholders, and stamps `VERSION.txt` and `bobba-client.json`.

## Publishing

`publish-release.ps1` builds the two assets the launcher downloads — `HabboAir.swf` and `HabboAirBobbaPatch.zip` (the upstream AirPlus patch base plus our packs and placeholders) — into `dist\release\`, then uploads them with `gh` to both the moving `latest` tag and a `vX.Y.Z` tag. Use `-SkipUpload` to build the assets without touching GitHub. The repo must stay public for the launcher to download anonymously:

- `https://github.com/Bobba-Packet/bobba-client/releases/download/latest/HabboAir.swf`
- `https://github.com/Bobba-Packet/bobba-client/releases/download/latest/HabboAirBobbaPatch.zip`

The launcher installs into `%AppData%\packet.bobba.launcher\downloads\airbobba\{version}\`, where the version is the SWF's `Last-Modified` epoch.
