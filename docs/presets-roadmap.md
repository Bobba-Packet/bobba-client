# Native Presets — Implementation Roadmap

[← Back to README](../README.md)

In-client export/import of room creations (furniture + wired), inspired by [G-Presets](https://github.com/sirjonasxx/G-Presets) but **not** a G-Earth MITM. The client already owns `roomEngine`, inventory, furnidata, and composers.

**Working plan (classes, algorithms, checklists):** [presets-plan.md](presets-plan.md)

**Status:** Phase 1 wired cache (open/save a box, then export)  
**Home:** HabboAirBobba (actor + UI) · optional later share via bobba-client-backend  
**JSON:** keep G-Presets `.json` compatible so existing community files load  
**Window pattern:** [Adding a custom window](custom-windows.md)

Related: Project Vision lists official-hotel automation as a grey zone. **Export + local files ship first.** Import is a room-rights builder robot (same composers a player would send), rate-limited, abortable — not a packet interceptor.

---

## 1. Goal and non-goals

| In | Out (v1) |
|---|---|
| Export a tile rectangle (or whole room) to JSON | G-Earth / packet sniffing |
| Native tile picker overlay on the room | Wall items (floor-only first) |
| Import furniture layout with a stack tile | Auto-donate / BC warehouse as default |
| Wired round-trip after geometry works | Rewriting hotel protocol |
| Availability vs inventory | Marketplace / paid presets |
| G-Presets JSON read/write | Server-side “paste room” (does not exist) |

**Ship rule:** each phase must be playable alone. Do not start import until export JSON is stable.

---

## 2. Visual product (what the user sees)

Three surfaces. Pixel art, Ubuntu, integer coords, `smoothing = false` — same rules as Bobba Helper.

### 2.1 Window — `:presets`

Habbo chrome (Illumina dark frame) wrapping a custom `Sprite` view.

| | |
|---|---|
| Command | `:presets` / `:preset` (also Helper → Extra) |
| View size | **420 × 448** (`VIEW_W` / `VIEW_H`) |
| Frame size | 432 × 484 (`+12` / `+36` margins) |
| Fill | `#000000` content, Helper greens for status |

```
┌─ Presets ───────────────────────────────────── x ┐
│  [Library]  [Export]  [Import]  [Settings]       │
│                                                   │
│  LIBRARY                                          │
│  ┌──────────────────────┐  ┌───────────────────┐  │
│  │ bopper               │  │ bopper            │  │
│  │ wired-timer        ● │  │ 12 × 8            │  │
│  │ score-counter        │  │ 24 furni · 6 wired│  │
│  │ my-gate-v2           │  │ Ready to import   │  │
│  └──────────────────────┘  └───────────────────┘  │
│                                                   │
│  [ Export selection ]  [ Import here ]            │
│  [ Check items ]       [ Open folder ]            │
│                                                   │
│  Room ●  Inventory ●  Stack tile ●  Rights ●      │
│  ───────────────────────────────────────────────  │
│  Exported "bopper" successfully                   │
└───────────────────────────────────────────────────┘
```

**Tabs**

| Tab | Purpose | Phase |
|---|---|---|
| Library | List local JSON, preview counts, select | 0 |
| Export | Name, whole-room vs selection, include wired | 1 |
| Import | Root XY, empty-tile hint, start / abort | 3 |
| Settings | Stack tile class, rate, incomplete builds, post-config | 2–3 |

**Readiness row** — four dots, Helper palette:

| Dot | Green | Amber | Red |
|---|---|---|---|
| Room | In a room | Entering | Not in room |
| Inventory | Loaded | Loading | Never requested |
| Stack tile | Found | — | Missing (import only) |
| Rights | Can move (+ wired if exporting wired) | — | No rights |

**Log strip** — last 4 lines, same role as G-Presets whisper spam, but inside the window. Still send a short room whisper for overlay steps so the user can look at the floor.

### 2.2 Room overlay — tile picker

Used by export (two corners) and import (empty tile, then root). **Do not hijack `MoveAvatar`.** Use room click + a `roomEngine` overlay.

```
        2nd click
           ↓
    ░░░░░░░░░░░░
    ░▓▓▓▓▓▓▓▓░░░   green = inside selection
    ░▓▓▓▓▓▓▓▓░░░   dim = outside
    ░▓▓▓▓▓▓▓▓░░░
    ░░░░░░░░░░░░
    ↑
  1st click

  ┌─────────────────────────────────────────┐
  │ Click opposite corner · 12 × 8 · Esc    │
  └─────────────────────────────────────────┘
```

| State | Overlay | Bottom bar |
|---|---|---|
| Export corner 1 | Tile cursor highlight | “Click first corner” |
| Export corner 2 | Filled rect + size | “Click opposite corner · W×H” |
| Export name | Rect stays | Text field + **Save** |
| Import empty tile | Single free tile pulse | “Click empty tile (state toggles)” |
| Import root | Ghost footprint of preset W×H | “Click where (0,0) should land” |
| Abort | — | Esc or `:abort` |

Ghost footprint: translucent tiles for every `PresetFurni` cell, offset to cursor. If it hangs off the floorplan (`x` tiles), tint those cells red.

### 2.3 Import HUD

A slim always-on-top strip (not the full window) while the robot runs. Window stays open on the Import tab, disabled.

```
┌──────────────────────────────────────────────────┐
│ Placing furniture     ████████░░░░  40 / 120     │
│ [ Abort ]                                        │
└──────────────────────────────────────────────────┘
```

Stages shown in order: Unstackables → Stackables → Ads → Wired → Move → Done.

Block room furni interaction while running (`setMouseEventsDisabledRect` is not enough — also ignore user `PlaceObject` / `MoveObject` from the UI). Keep `:abort` working.

### 2.4 Assets (`brand-pack/presets/` → `bobba/presets/`)

Nothing baked into the SWF. Sprite sheets = horizontal frames.

| File | Size / frames | Use |
|---|---|---|
| `tab.png` | 3-frame `idle \| hover \| active` | Library / Export / Import / Settings |
| `btn.png` | 3-frame `normal \| hover \| click` | Primary actions |
| `btn-disabled.png` | 1-frame | Disabled primary |
| `dot.png` | 3-frame `red \| amber \| green` | Readiness |
| `list-row.png` | 2-frame `idle \| selected` | Preset list |
| `progress.png` | Track + fill (9-slice or stretch) | Import HUD |
| `tile-ok.png` / `tile-bad.png` | 32×16 isometric diamond (or 1×1 floor) | Overlay |
| `i18n` keys | in existing locale JSON | All chrome strings |

Reuse Helper `checkbox.png` for settings toggles. Reuse Ubuntu / `#31A342` / `#C9A227` / `#C0392B` / `#6E6E6E`.

### 2.5 i18n keys (add to `en` / `pt-BR` / `es`)

```
presets.title
presets.tab.library | export | import | settings
presets.action.exportSelection | exportAll | importHere | checkItems | openFolder | abort | save
presets.ready.room | inventory | stackTile | rights
presets.overlay.corner1 | corner2 | name | emptyTile | root
presets.hud.unstackables | stackables | ads | wired | move | done
presets.log.exported | imported | aborted | missingItems | noStackTile
```

---

## 3. Architecture

```
User
  │  :presets / overlay clicks
  ▼
BobbaPresetsEditor  ── Habbo frame (XML)
  └── BobbaPresetsView  ── pixels, tabs, list, log
        │
        ▼
BobbaPresetsController   (file-private helper, merge into window manager host)
  ├── Snapshot   roomEngine + inventory + IFurnitureData
  ├── Exporter   rectangle → PresetConfig JSON
  ├── Importer   JSON → composers + wait for room events
  └── Store      applicationStorageDirectory/presets/*.json
        │
        ▼  (phase 5 only)
BobbaBackendClient   share / download  (sidecar, not hotel)
```

Hotel traffic stays on stock composers (`PlaceObject`, `MoveObject`, `UseFurniture`, `SetCustomStackingHeight`, `UpdateAction`, …). The sidecar never sees those packets.

**FFDec:** new classes go in `cleanswf/scripts/com/sulake/habbo/window/utils/bobba/`, listed in `merge.helpers`. No new ABC class names in the SWF.

**Do not rebuild `FloorState` from packets.** Iterate room objects. Wait on room-engine add/update events (with a timeout), not `Thread.sleep` plus ping hacks.

---

## 4. Phases

### Phase 0 — Shell (3–5 days)

**Ship:** window opens, empty library, overlay can highlight one tile.

| # | Work |
|---|---|
| 0.1 | `BobbaPresetsEditor` + `BobbaPresetsView` + frame XML |
| 0.2 | `:presets` in `LilithCustoms` + Helper Extra button |
| 0.3 | Tab chrome + readiness dots (Room only wired) |
| 0.4 | JSON types: `PresetFurni`, `PresetConfig` (wired arrays empty) |
| 0.5 | Disk store: list / read / write / open folder |
| 0.6 | Tile picker v0: one-click highlight + Esc |
| 0.7 | `brand-pack/presets/` + i18n stubs |

**Done when:** `:presets` shows a window, creating an empty JSON file from a button works.

### Phase 1 — Export (1–2 weeks) — first public slice

**Ship:** select a rectangle, save G-Presets-compatible JSON, reload it in the list.

| # | Work |
|---|---|
| 1.1 | Two-click rect overlay + W×H + name field |
| 1.2 | Walk floor items in rect via `roomEngine` |
| 1.3 | Map typeId → `className` via `IFurnitureData` |
| 1.4 | Relative XY, Z minus lowest floor, IDs `1..n`, names `className[n]` |
| 1.5 | Stuffdata state for legacy toggles; `ads_background` map |
| 1.6 | Wired **cache**: hook official save composers as the user edits |
| 1.7 | Wired **fetch**: for unknown boxes, request config through the client wired API (do not spam `Open` into the UI) |
| 1.8 | `:ep` / `:ep all` / `:abort` |
| 1.9 | Load existing G-Presets files (ignore unknown keys) |

**Done when:** export a wired-ish corner, open the JSON, and it matches G-Presets field names (`furni`, `wired`, `bindings`, `adsBackgrounds`).

### Phase 2 — Availability + post-config (3–5 days)

**Ship:** “Check items” and “use this existing furni instead of placing”.

| # | Work |
|---|---|
| 2.1 | Request inventory if not loaded; count by `className` |
| 2.2 | Availability panel: have / need / missing |
| 2.3 | Post-config table: `furniName` → existing room item id |
| 2.4 | Settings: allow incomplete builds |

**Done when:** a preset that needs 3 glowballs shows 2/3 if inventory has two.

### Phase 3 — Geometry import (2 weeks)

**Ship:** recreate furniture positions (no wired). Needs a stack tile in the room.

| # | Work |
|---|---|
| 3.1 | Settings: stack tile classname (1×1 / 2×2 / …) |
| 3.2 | Overlay: empty tile then root (or `:ip x,y`) |
| 3.3 | Place unstackables at final XY (`PlaceObjectMessageComposer`) |
| 3.4 | Park stack tile; dump stackables onto it |
| 3.5 | Map preset id → real id from **roomEngine add**, keyed `x\|y\|typeId` |
| 3.6 | `SetCustomStackingHeight` + `MoveObject` to final XY/rot/Z |
| 3.7 | State: prefer `WiredSetObjectVariableValue` (`-110`); else toggle on the empty tile |
| 3.8 | Rate limit from events + a settings slider (default ~150 ms place) |
| 3.9 | HUD + abort that actually stops the queue |
| 3.10 | Restore stack tiles to original tiles |

**Done when:** a 20-item non-wired preset lands at the clicked origin with correct heights.

### Phase 4 — Wired import (2 weeks)

**Ship:** boxes save with remapped furni/variable ids.

| # | Work |
|---|---|
| 4.1 | Remap `wiredId` / selected items through the id map |
| 4.2 | Variable name → new id |
| 4.3 | Snapshot bindings: pose bound furni → save → restore |
| 4.4 | Save order: variables → conditions → effects → triggers → addons → selectors |
| 4.5 | Wait `WiredSaveSuccess`; retry twice |
| 4.6 | Skip boxes whose furni was missing (if incomplete builds on) |

**Done when:** the included “bopper” (or a small self-exported timer) works after import.

### Phase 5 — Share (1–2 weeks, after sidecar capacity)

**Ship:** upload/download for the logged-in Bobba account. Not required for v1.

| # | Work |
|---|---|
| 5.1 | TCP packets: list / get / put preset JSON (no hotel secrets) |
| 5.2 | Library section “Bobba” vs “This device” |
| 5.3 | Hotel-scoped (`hotelId`); classNames are hotel-specific |
| 5.4 | Optional showcase on the website later |

---

## 5. Commands

| Command | Action |
|---|---|
| `:presets` / `:preset` | Toggle window |
| `:ep` / `:exportpreset` | Start two-click export |
| `:ep all` | Export whole room, ask name |
| `:ip` / `:importpreset` | Start import overlays |
| `:ip 0,0` | Import with root skipped |
| `:abort` / `:a` | Cancel export or import |

---

## 6. Suggested file list

All under `cleanswf/scripts/com/sulake/habbo/window/utils/bobba/` unless noted.

| File | Phase | Role |
|---|---|---|
| `BobbaPresetsEditor.as` | 0 | Frame, mouse-block rect, lifecycle |
| `BobbaPresetsView.as` | 0 | Tabs, list, buttons, log, HUD |
| `BobbaPresetsController.as` | 0 | Orchestrates snapshot / export / import / store |
| `BobbaPresetConfig.as` | 0 | JSON parse/serialize |
| `BobbaPresetFurni.as` | 0 | One furniture row |
| `BobbaPresetStore.as` | 0 | Disk IO |
| `BobbaTilePicker.as` | 0–1 | Room overlay |
| `BobbaRoomSnapshot.as` | 1 | Floor items + height + className |
| `BobbaPresetExporter.as` | 1 | Normalize + wired attach |
| `BobbaWiredCache.as` | 1 | Listen to wired saves / fetches |
| `BobbaAvailability.as` | 2 | Inventory diff |
| `BobbaPresetImporter.as` | 3 | Queue of place/move/save steps |
| `BobbaStackTiles.as` | 3 | Find / park / height |
| Wired preset types | 4 | Trigger / condition / effect / addon / selector / variable |

Hook `displayPresets()` on `HabboWindowManagerComponent` (same as Helper / Trax). Add helpers to `patches/manifest.json` `merge.helpers`.

---

## 7. JSON (G-Presets compatible)

```json
{
  "furni": [
    {
      "id": 1,
      "className": "wf_trg_walks_on_furni",
      "name": "wf_trg_walks_on_furni[0]",
      "location": { "x": 0, "y": 0, "z": 0.0 },
      "rotation": 0,
      "state": "0"
    }
  ],
  "wired": {
    "conditions": [],
    "effects": [],
    "triggers": [],
    "addons": [],
    "selectors": [],
    "variables": [],
    "variables_map": {}
  },
  "bindings": [],
  "adsBackgrounds": []
}
```

Unknown keys: ignore. Missing `adsBackgrounds`: empty array. Wired boxes keep `wiredId`, `options`, `config`, `items`, `secondItems`, `furniSources`, `userSources`, `variableIds`.

Storage: `File.applicationStorageDirectory/presets/<name>.json`.

---

## 8. Risks

| Risk | Mitigation |
|---|---|
| FFDec merge size | Keep View dumb; Controller does the queue |
| Hotel rate limits | Event waits + slider; never burst |
| Wired schema drift | Version a `format: 1` later; v1 = G-Presets 1.2.x |
| Stack tile missing | Import disabled until found; show which class is expected |
| User clicks during import | Disable placement UI; `:abort` |
| ToS / vision grey zone | Export is the advertised feature; import behind Settings “Builder tools” |

---

## 9. First spike (do this before Phase 0 polish)

1. Empty `:presets` window (copy Helper Editor/View, strip to a title + one button).
2. Dump **all** floor items in the current room to one JSON via a debug button (no picker yet).
3. Reload that file into the list and show `className` counts.

If that works, the native path is proven: snapshot from `roomEngine`, persist JSON, no G-Earth.
