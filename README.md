# Bobba Client (HabboAirBobba)

A playable Adobe AIR Habbo client: a fork of [HabboAirPlus](https://github.com/LilithRainbows/HabboAirPlus) with Bobba branding and extra in-client tools. There is no Flash Builder project here — the client is shipped by injecting edited ActionScript 3 back into the AIR SWF with [JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler).

Repo: https://github.com/Bobba-Packet/bobba-client · License: GPL-3.0 · Community project, not affiliated with Sulake.

---

## What it adds over AirPlus

- **Branding** on the login, SSO, loading and photo splash screens, loaded from disk so PNG swaps need no re-inject.
- **Bobba Helper** (`:bobba`) — a pixel-art window with Anti AFK, Auto drop, turn block and the wall-item mover.
- **Wall item mover** — an arrow pad on the wall-furni infostand that nudges posters pixel by pixel.
- **Trax Machine** (`:traxmachine` / `:trax`) — an in-client song editor with a multi-layer timeline, streaming its sounds from an external pack.
- **Avatar editor Clothes button**, **local room placeholder SWFs** (the CDN 404s them), and a **file logger** for ADL debugging.

Full details in [Features](docs/features.md).

## Quick start

```powershell
powershell -ExecutionPolicy Bypass -File tools\inject-scripts.ps1   # build HabboAir_bobba.swf
tools\update-and-debug.bat                                          # run it under ADL
```

You need Java, the FFDec CLI, an AIR SDK, the upstream `HabboAir.swf` at the repo root, and its AS3 export in `cleanswf\scripts\`. [Getting started](docs/getting-started.md) covers all of it.

## Documentation

| Doc | What's in it |
|---|---|
| [Features](docs/features.md) | What the client does, command by command |
| [Getting started](docs/getting-started.md) | Requirements, repo layout, the edit → inject → debug loop |
| [Editing ActionScript](docs/editing-actionscript.md) | `patches/manifest.json`, the merge trick, FFDec rules, chat commands |
| [Assets](docs/assets.md) | How runtime paths resolve, and what lives in each pack |
| [Adding a custom window](docs/custom-windows.md) | Editor/View pattern used by Bobba Helper and Trax Machine |
| [Package and release](docs/packaging.md) | `dist\airbobba`, the patch zip, and the launcher download URLs |
| [Troubleshooting](docs/troubleshooting.md) | Symptom → cause table |
| [Conventions](docs/conventions.md) | Project rules, licensing and brand notes |
