# Assets

[← Back to README](../README.md)

Nothing new is baked into the SWF. At runtime the client resolves a relative path in this order:

1. `File.applicationDirectory/<path>`
2. `File.applicationDirectory/local_include/<path>`
3. a fallback under `applicationStorageDirectory`

So every pack is deployed twice, next to the SWF and under `local_include/`.

## `brand-pack/` → `bobba/`

Login/loading backgrounds and logo (`bg_pattern_darktile.png`, `bg_pattern_bobbaskulls1.gif`, `logo-bobba-client.png`, `shadow.png`), the polaroid frame (`splash_pictures_no_pixel.png`, 838×302 at runtime), Bobba Helper chrome (`bobba-client-logo-splash.png` 124×108, `bobba-flower.png` 35×93, `bobba-discord-btn.png` / `bobba-settings-btn.png` 300×26), the avatar-editor Clothes button (`bobba_clothes_btn.png` 110×30, `bobba_clothes_hero.png` 485×109), the bottom-bar Helper button (`bobba_menu.png` 114×38, three 38×38 frames), `checkbox.png` (36×18), group chat icons (`group-chat.png` / `group-chat-unread.png`, **33×33**), `wallmover/` arrows, and **`i18n/` locale JSON** (`en.json`, `pt-BR.json`, `es.json`, `fr.json`).

Sprite sheets follow the Habbo convention — horizontal frames, left to right: two-state is `off | on` (`frameWidth = image.width / 2`), three-state buttons are `normal | hover | click`.

### i18n

Bobba chrome strings (Helper, group chat, Bobba toggle whispers) load from disk via `BobbaI18n` + `BobbaPack`:

| Hotel (`-server` / `BobbaClient.hotelId`) | Locale file |
|---|---|
| `hhbr` | `bobba/i18n/pt-BR.json` |
| `hhes` | `bobba/i18n/es.json` |
| `hhfr` | `bobba/i18n/fr.json` |
| everything else | `bobba/i18n/en.json` |

English is also the missing-key fallback. Edit the JSON under `brand-pack/i18n/` — no re-inject needed for string-only changes (re-run `update-and-debug.bat` or redeploy the pack). Code that adds a new string must call `BobbaI18n.t("key")` (merged UI) or `windowManager.bobbaT("key")` (`LilithCustoms`).

## `client-assets/local_include/` → `local_include/`

`HabboRoomContent.swf`, `PlaceHolderFurniture.swf`, `PlaceHolderPet.swf`, `PlaceHolderWallItem.swf`, `SelectionArrow.swf`, `TileCursor.swf`, and Bobba-only avatar FX (`NPCkey.swf` as fx 9002, `BobbaKey.swf` as fx 9001). Official Metakey (fx 212) still loads from the hotel CDN. AirPlus checks `FileProxy.localFileExists` before hitting the CDN; without the placeholders you get `COMPONENT_EVENT_ERROR` right after login. NPCkey and BobbaKey are picked from the wardrobe Effects tab and never talk to the Habbo hotel — other Bobba clients see them via the sidecar.

## `traxmachine-pack/` → `traxmachine/`

The Trax Machine's `catalog.json`, `imgs/` and `sounds/` (~57 MB, gitignored). Without it the editor opens but reports that `catalog.json` was not found.

## `client-assets/illumina-dark-atlas/`

Slices of the dark window skin (theme style **200**), cut from `cleanswf/scripts/_assets/2332_habbo_skin_illumina_dark_1_png.png` (243×137) by `tools/export-illumina-dark-atlas.py`. `01_frame/` feeds frames, `02_button/` buttons and container buttons, `03_border_and_header/` both borders and headers (identical pixels), `04_extra_unreferenced/` is in the atlas but unused by the current skin XMLs. Scrollbars use their own `illumina_dark_scrollbar_*` PNGs.

## Layout tweakers

Browser-based helpers in `tools/` (open the `.html` over `file://` or a local static server). They must not call `canvas.toDataURL()` on local images (it taints the canvas) — they clip with CSS instead.

| Tool | Purpose |
|---|---|
| `bobba-helper-tweaker.html` | Bobba Helper (`:bobba`) content layout → AS3 constants for `BobbaHelperView.as` |
| `bobba-settings-tweaker.html` | Bobba Settings window layout (sidebar + topics from `docs/settings-window-spec.md`) → AS3 constants for a future `BobbaSettingsView` / frame XML |
| `polaroid-tweaker.html` | Photo splash polaroid slots |

Settings tweaker defaults assume a left sidebar, scrollable content, and an optional search bar. Export includes `VIEW_W`/`VIEW_H` plus the frame size formula (`+12` / `+36` margins).
