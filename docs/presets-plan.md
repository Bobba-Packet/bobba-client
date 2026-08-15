# Native Presets — Detailed Implementation Plan

[← Back to README](../README.md) · High-level: [presets-roadmap.md](presets-roadmap.md) · Window recipe: [custom-windows.md](custom-windows.md)

This is the **working plan**. The roadmap is the product outline. Follow this file when writing code.

**Status:** Phase 1 wired cache in progress. Open or save boxes, then export.  
**Constraint:** no G-Earth, no packet MITM. Hotel composers only, sent like a player.  
**JSON:** G-Presets 1.2.x compatible (`furni`, `wired`, `bindings`, `adsBackgrounds`).  
**FFDec:** `//` comments only. New types = `merge.helpers`. Never touch `IHabboWindowManagerComponent.as`.

---

## 0. How to use this plan

1. Finish **Spike S0** before any UI polish.
2. Land one phase per PR. Do not start Phase N+1 until the phase Done checklist is true in ADL.
3. Confirm composer **class names** in the local `cleanswf` tree (gitignored) at the start of Phases 1 and 3 — names below are the Sulake/G-Earth mapping to search for.
4. After each inject: size **delta ≠ 0**, then `:presets` in-game.

Related G-Presets source: [sirjonasxx/G-Presets](https://github.com/sirjonasxx/G-Presets) (`GPresetExporter.java`, `GPresetImporter.java`, `FloorState.java`).

---

## 1. Hard rules (do not violate)

| Rule | Why |
|---|---|
| No new ABC class names in the SWF | FFDec cannot add them; helpers merge into `HabboWindowManagerComponent.as` as file-private classes |
| Do not stage `IHabboWindowManagerComponent`, `Core`, `EventDispatcherWrapper` | Breaks ABC slots |
| Do not parse hotel `Objects` / `ObjectAdd` packets to rebuild a shadow room | `roomEngine` already is the room |
| Do not hijack `MoveAvatar` for tile pick | Native overlay / room click |
| Do not `Thread.sleep` as the wait primitive | Wait on room-engine events + timeout; optional extra delay from settings |
| Sidecar never sends Place/Move/Wired | Hotel traffic stays on `communication.connection` |
| Export ships before import | Import is a rate-limited robot; JSON must be stable |
| Import is a builder tool (room rights) | Not advertised as a bypass; abortable; rate-limited |
| Wall items out of v1 | Floor only |
| BC auto-place / autodonate out of v1 | Inventory only until Phase 3.1 extra is explicitly added |

---

## 2. Spike S0 (do this first, ~half a day)

Goal: prove `roomEngine → JSON file → list` with an ugly window. No picker, no wired, no import.

### S0.1 Copy the window skeleton

Copy `BobbaHelperEditor.as` / `BobbaHelperView.as` → `BobbaPresetsEditor.as` / `BobbaPresetsView.as`.

Strip the View to:

- black `graphics.beginFill(0x000000)` over `VIEW_W=420`, `VIEW_H=200` (tiny is fine)
- one title `TextField` (`Ubuntu bold`, 15, `0xFFFFFF`)
- one 3-frame button **Dump room** (reuse Helper `bobba-settings-btn.png` temporarily)
- one `TextField` showing `N floor items` after dump

Editor XML: same pattern as Helper, canvas 420×200, frame `432×236` (`+12` / `+36`).

`MOUSE_BLOCK_KEY = "bobba_presets"`.

### S0.2 Host hooks (minimal)

**`HabboWindowManagerComponent.as`** (implementation only):

```
private var _bobbaPresetsEditor:BobbaPresetsEditor;

public function displayPresets() : void
{
   if(_bobbaPresetsEditor == null)
   {
      _bobbaPresetsEditor = new BobbaPresetsEditor(this);
   }
   _bobbaPresetsEditor.visible = true;
}

public function hidePresets() : void
{
   if(_bobbaPresetsEditor != null)
   {
      _bobbaPresetsEditor.visible = false;
   }
}
```

Call `_bobbaPresetsEditor.dispose()` from the existing window-manager `dispose` path (same as Helper/Trax).

**`LilithCustoms.as`:**

- `AllowedCommands`: `presets`, `preset`
- `ParseChatInput`: if chat is `:presets` or `:preset` → `WindowManager.displayPresets()`, block the chat from the room (same as `:bobba`)

**`patches/manifest.json` `merge.helpers`:** append after `BobbaHelperEditor.as`:

```
com/sulake/habbo/window/utils/bobba/BobbaPresetFurni.as
com/sulake/habbo/window/utils/bobba/BobbaPresetConfig.as
com/sulake/habbo/window/utils/bobba/BobbaPresetStore.as
com/sulake/habbo/window/utils/bobba/BobbaRoomSnapshot.as
com/sulake/habbo/window/utils/bobba/BobbaPresetsController.as
com/sulake/habbo/window/utils/bobba/BobbaPresetsView.as
com/sulake/habbo/window/utils/bobba/BobbaPresetsEditor.as
```

Order: **leaves before users**. Editor last among presets (it constructs View).

### S0.3 Dump current room

`BobbaRoomSnapshot.captureAllFloorItems(windowManager) : Array` of `BobbaPresetFurni` (raw hotel ids, absolute XY/Z).

Algorithm (confirm categories in `RoomObjectCategoryEnum` / `IRoomEngine`):

```
roomId = session.roomId   // LilithCustoms.RoomSession or roomEngine.roomSessionManager
category = 10             // floor furniture (users are 100 — confirmed in BobbaGroupWhisperController)
count = roomEngine.getRoomObjectCount(roomId, category)
for i in 0 .. count-1:
  obj = roomEngine.getRoomObject(roomId, i, category)  // or getRoomObject(roomId, id, category) — confirm API
  read location (x, y, z), direction, typeId, id
  className = furnitureData.className for typeId
```

If `getRoomObjectCount` is not on `IRoomEngine`, iterate via `roomEngine.getRoomObjectManager` / existing AirPlus helpers. Probe in ADL with `Logger.log`.

Write `File.applicationStorageDirectory/presets/_debug.json` via `BobbaPresetStore.save`.

### S0.4 Spike Done

- [x] Inject delta ≠ 0 (`HabboAir_bobba.swf` +133554)
- [x] `:presets` opens a black Habbo frame
- [x] Dump writes `_debug.json` with at least `furni[].className` + `location`
- [x] Closing the window removes `bobba_presets` mouse-block rect

Do **not** proceed to tabs/assets until this is true.

---

## 3. Target architecture

```
LilithCustoms.ParseChatInput
        │ :presets :ep :ip :abort
        ▼
HabboWindowManagerComponent.displayPresets()
        ▼
BobbaPresetsEditor          Habbo XML frame + mouse-block
  └── BobbaPresetsView      pixels (tabs, list, log, HUD)
        │ callbacks
        ▼
BobbaPresetsController      only state machine owner
  ├── BobbaPresetStore      disk JSON
  ├── BobbaRoomSnapshot     roomEngine read
  ├── BobbaPresetExporter   normalize + wired attach
  ├── BobbaWiredCache       listen to wired save/open in the official UI
  ├── BobbaTilePicker       room overlay (not MoveAvatar)
  ├── BobbaAvailability     inventory counts
  └── BobbaPresetImporter   step queue (Phase 3+)
        │
        ▼
windowManager.communication.connection.send(composer)
```

**View is dumb.** It does not send composers. Controller calls `view.setTab`, `view.setList`, `view.log`, `view.setHud`, `view.setReady`.

**No packet interceptors.** Wired cache hooks the **client’s own** save path (composer factory or wired widget save handler), not G-Earth `intercept()`.

---

## 4. Files to add / patch

### 4.1 New helpers (all under `cleanswf/scripts/com/sulake/habbo/window/utils/bobba/`)

| File | Phase | Responsibility |
|---|---|---|
| `BobbaPresetFurni.as` | 0 | One furniture row; `toObject()` / `fromObject()` |
| `BobbaPresetWired.as` | 1 | Shared wired box fields + JSON |
| `BobbaPresetBinding.as` | 1 | Snapshot binding |
| `BobbaPresetAds.as` | 1 | ads_background stuffdata |
| `BobbaPresetConfig.as` | 0 | Root JSON object |
| `BobbaPresetStore.as` | 0 | list / load / save / reveal folder |
| `BobbaRoomSnapshot.as` | 0 | Floor items, height, className, stackables |
| `BobbaPresetsSettings.as` | 0 | SharedObject keys |
| `BobbaPresetsController.as` | 0 | Orchestrator |
| `BobbaPresetsView.as` | 0 | Pixel UI |
| `BobbaPresetsEditor.as` | 0 | Frame XML |
| `BobbaTilePicker.as` | 0–1 | Overlay states |
| `BobbaPresetExporter.as` | 1 | Four-pass normalize |
| `BobbaWiredCache.as` | 1 | Map wiredId → config |
| `BobbaAvailability.as` | 2 | className → have/need |
| `BobbaImportQueue.as` | 3 | Step list + runner |
| `BobbaPresetImporter.as` | 3 | Build the queue from a config |
| `BobbaStackTiles.as` | 3 | Find / park / height |

### 4.2 Existing files to patch

| File | Change |
|---|---|
| `patches/manifest.json` | `merge.helpers` list (order in §2) |
| `HabboWindowManagerComponent.as` | `displayPresets` / `hidePresets` / dispose; **not** the interface |
| `LilithCustoms.as` | commands in §8 |
| `BobbaHelperView.as` | Extra row `presets` → `displayPresets()` (clone Trax row) |
| `brand-pack/i18n/en.json` `pt-BR.json` `es.json` | keys in §12 |
| `docs/features.md` | only after Phase 1 ships |
| `docs/assets.md` | `brand-pack/presets/` after assets exist |

### 4.3 Assets (Phase 0 polish, after S0)

Create `brand-pack/presets/`. Deploy via existing pack copy (same as Helper). Paths resolve as `bobba/presets/...` through `BobbaPack.resolveUrl`.

| File | Spec |
|---|---|
| `tab.png` | 3 frames L→R: idle, hover, active. Height 22. Width per tab ~72 |
| `btn.png` | 3 frames: normal, hover, click. Height 22 |
| `btn-disabled.png` | 1 frame, same size as one `btn` frame |
| `dot.png` | 3 frames: red `#C0392B`, amber `#C9A227`, green `#31A342`. 6×6 or 8×8 |
| `list-row.png` | 2 frames: idle, selected. Width 240, height 22 |
| `progress-track.png` / `progress-fill.png` | HUD bar |
| `tile-ok.png` | isometric floor diamond or 1×1; used as overlay stamp |
| `tile-bad.png` | same, red tint |

Until art exists: draw with `graphics` (Helper does this for the status tag). Do not block S0/P1 on PNGs.

---

## 5. Class contracts

AS3. No `/**`. Public methods only as needed. Use `Array` not Vector if FFDec is picky (Helper uses Array/Dictionary).

### 5.1 `BobbaPresetFurni`

```
id:int                 // normalized 1..n in files; hotel id only in snapshots
className:String
name:String            // "glowball[0]"
x:int
y:int
z:Number
rotation:int           // 0..7 facing ordinal (match G-Presets HPoint facing)
state:String           // null if none / wired
```

`toObject():Object` keys: `id`, `className`, `name`, `location:{x,y,z}`, `rotation`, optional `state`.  
`fromObject(o:Object):BobbaPresetFurni` — ignore unknown keys.

### 5.2 `BobbaPresetConfig`

```
furniture:Array        // BobbaPresetFurni
wired:Object           // { conditions, effects, triggers, addons, selectors, variables, variables_map }
bindings:Array         // BobbaPresetBinding
adsBackgrounds:Array   // BobbaPresetAds
```

`toObject()` / `fromObject()` / `toJsonString():String` (`JSON.stringify(obj)`) / `fromJsonString(s:String)`.

Missing `adsBackgrounds` → `[]`. Missing wired arrays → `[]`. Unknown keys ignored.

### 5.3 `BobbaPresetWired` (one box)

```
kind:String            // "trigger"|"condition"|"effect"|"addon"|"selector"|"variable"
wiredId:int
options:Array          // ints
config:String          // stringConfig
items:Array            // int furni ids (normalized)
secondItems:Array
furniSources:Array
userSources:Array
variableIds:Array      // strings
extra:Object           // type-specific fields from G-Presets appendJsonFields
```

JSON field names must match G-Presets: `wiredId`, `options`, `config`, `items`, `secondItems`, `furniSources`, `userSources`, `variableIds`.

### 5.4 `BobbaPresetBinding`

```
furniId:int
wiredId:int
location:Object        // {x,y} or null
rotation:Object        // int or null
state:String           // or null
altitude:Object        // int hundredths or null
```

G-Presets classes that **require** bindings: `wf_act_match_to_sshot`, `wf_cnd_match_snapshot`, `wf_cnd_not_match_snap`, `wf_trg_stuff_state`.

### 5.5 `BobbaPresetStore`

```
static function dir() : File
  // File.applicationStorageDirectory.resolvePath("presets")
  // mkdir if needed

static function listNames() : Array          // without .json
static function load(name:String) : BobbaPresetConfig
static function save(name:String, cfg:BobbaPresetConfig) : Boolean
static function reveal() : void              // File.presetsDir.openWithDefaultApplication() if available
static function validName(name:String) : Boolean
  // reject <>:"/\|?*  (G-Presets rule)
```

UTF-8. Pretty-print with 2-space indent if `JSON.stringify` supports it; otherwise compact is OK for v1.

### 5.6 `BobbaPresetsSettings` (SharedObject `HabboAirPlus`, same as AirPlus)

| Key | Type | Default |
|---|---|---|
| `BobbaPresetsStackTile` | String className | `tile_stackmagic` or first detected 2×2 |
| `BobbaPresetsRatePlaceMs` | int | 150 |
| `BobbaPresetsRateMoveMs` | int | 60 |
| `BobbaPresetsAllowIncomplete` | Boolean | false |
| `BobbaPresetsExportWired` | Boolean | true |
| `BobbaPresetsBuilderEnabled` | Boolean | false (import gated until user opts in) |

Read/write through `LilithCustoms` if that is how other Bobba keys work (`GetBobbaToggle` / `SetBobbaToggle`); otherwise a tiny helper around `SharedObject.getLocal("HabboAirPlus","/")`. Match existing pattern — do not invent a second SOL.

### 5.7 `BobbaPresetsController` states

```
enum Mode:
  IDLE
  EXPORT_CORNER1
  EXPORT_CORNER2
  EXPORT_NAME
  EXPORT_FETCH_WIRED
  IMPORT_EMPTY_TILE
  IMPORT_ROOT
  IMPORT_RUNNING
```

Only one mode at a time. `:abort` → `IDLE`, picker hide, importer cancel flag, log `presets.log.aborted`.

Public API for View/Editor/Lilith:

```
open()
close()
startExportSelection()
startExportAll()
startImport()          // uses selected preset
startImportAt(x,y)
abort()
selectPreset(name)
checkAvailability()
dumpDebug()            // keep from S0, hide later
```

### 5.8 `BobbaTilePicker` overlay states

```
OFF
CORNER1
CORNER2(x1,y1)
EMPTY_TILE
ROOT(presetW, presetH, ghostCells)
```

Input: room tile clicks. Output: callback `(x,y)`. Esc → controller.abort().

**Implementation order:**

1. Phase 0: listen for tile selection the client already has (probe `roomEngine` events / tile cursor). Log `x,y` on click.
2. Phase 1: draw a `Sprite` overlay parented to the room visualization or stage, stamp `tile-ok` on cells in the rect, convert screen→tile using the same geometry the tile cursor uses.
3. Never `setBlocked` on `MoveAvatar`.

If overlay-on-visualization is too hard in P0, a **click-to-confirm infostand** is unacceptable (too slow). Fallback: whisper “walk to the tile and type `:ep mark`” is also unacceptable. Spend the time to find `IRoomEngine` tile-click. Search cleanswf:

```
*RoomEngineObjectEvent*
*RoomObjectTileMouseEvent*
*RoomObjectMouseEvent*
*getSelectedObject*
```

### 5.9 Composer send helper

```
BobbaHotelSend.send(windowManager, composer) : Boolean
```

Wraps:

```
windowManager.communication.connection.send(composer)
```

Same pattern as `BobbaGroupChatController.openUserProfile`. Catch errors, log, return false.

---

## 6. Hotel composers — investigation checklist

G-Earth names → search `cleanswf/scripts/com/sulake/habbo/communication/messages/outgoing/**`.

Run once at Phase 1 / 3 start (PowerShell from repo root):

```
Get-ChildItem cleanswf\scripts\com\sulake\habbo\communication\messages\outgoing -Recurse -Filter *.as |
  Select-String -Pattern "class (PlaceObject|MoveObject|UseFurniture|PickupObject|SetCustomStackingHeight|SetObjectData|UpdateAction|UpdateTrigger|UpdateCondition|UpdateAddon|UpdateSelector|UpdateVariable|OpenWired|WiredSetObject|WiredGetAll|BuildersClubPlace|RequestFurniInventory)" |
  ForEach-Object { $_.Path + " :: " + $_.Line }
```

| G-Earth / hotel name | Role | Phase |
|---|---|---|
| `PlaceObject` | Inventory drop. Payload historically `"-id x y rot"` as **one string** | 3 |
| `MoveObject` | `id, x, y, rot` | 3 |
| `UseFurniture` | Toggle state `id, 0` | 3 |
| `SetCustomStackingHeight` | Magic tile height, **hundredths** | 3 |
| `SetObjectData` | ads_background map | 3 |
| `Open` | Open wired box (avoid popping UI — prefer client API) | 1 |
| `UpdateTrigger` `UpdateCondition` `UpdateAction` `UpdateAddon` `UpdateSelector` `UpdateVariable` | Save wired | 1 cache / 4 apply |
| `WiredSetObjectVariableValue` | `0, furniId, "-110", intState` | 3 |
| `WiredGetAllVariablesDiffs` | Variable id map | 1 / 4 |
| `RequestFurniInventory` | Load inventory | 2 |
| `BuildersClubPlaceRoomItem` | Out of v1 | — |

Incoming we **do not parse**. Instead:

| Need | Native source |
|---|---|
| New furni id after place | `roomEngine` object-added event **or** snapshot diff (ids that appeared at `x,y,typeId`) |
| Wired save ack | Wired widget / session event if exposed; else timeout + snapshot |
| Inventory | Inventory furni model already in client |
| Furniture className | `IFurnitureData` via `sessionDataManager` / catalog (see `BobbaLegacyPriceDialog`) |

Document the exact class + constructor args in this file when found (append §6.1). Do not guess argument order in the importer.

---

## 7. Algorithms

### 7.1 Snapshot one floor item

For each room object in floor category:

| Field | Source (confirm names) |
|---|---|
| id | `roomObject.getId()` |
| typeId | `roomObject.getType()` or furniture type id on model |
| x,y | location / `getLocation()` |
| z | location.z |
| rotation | direction / facing |
| className | `IFurnitureData.className` for typeId |
| state | stuffdata / `IStuffData.getLegacyString()` if category 0 |
| stackable | furnidata `canStandOn` / `isStackable` — **must confirm** |
| ads | if className `ads_background` and stuff is map: `imageUrl, offsetX, offsetY, offsetZ` |

Skip the user’s selected stack tile class on export? **No** — include it; import will place a new one if present in the preset. Document that exporting the stack tile you need for import is optional.

### 7.2 Export rectangle (G-Presets four passes)

Input: `x0,y0,x1,y1` inclusive. Swap so `x0<=x1`, `y0<=y1`. `:ep all` → bounding box of all floor items, or `0,0`–`mapW,mapH`.

**Pass 1 — collect**

For each tile in rect, all furni whose **root tile** is in rect (not every occupied cell of a 2×2 — use the object’s origin, same as G-Presets `getFurniOnTile` which keys by origin).

Build `allFurni`, wired lists by class prefix:

| Prefix | List |
|---|---|
| `wf_trg_` | triggers |
| `wf_cnd_` | conditions |
| `wf_act_` | effects |
| `wf_xtra_` | addons |
| `wf_slc_` | selectors |
| `wf_var_` | variables |

If `BobbaPresetsExportWired` is false, skip wired lists and bindings.

For each wired in area: if cache miss → queue id for fetch (Phase 1.7). If still missing after fetch → fail export (unless export-wired off).

**Pass 2 — clip selections**

Drop `items` / `secondItems` / bindings whose furni id is not in `allFurni`.

**Pass 3 — normalize**

- `lowestZ` = min floor height in rect (tile height, not furni z) — G-Presets `PresetUtils.lowestFloorPoint`
- Map hotelId → `1..n` in collection order
- Subtract `(x0,y0,lowestZ)` from locations
- Binding altitude: `old - lowestZ*100` if present

**Pass 4 — names**

`className[n]` incrementing per class. Clear `state` on all `wf_*` furniture.

Write JSON. Refresh library. Whisper + log `presets.log.exported`.

### 7.3 Wired cache (Phase 1)

Whenever the **user** saves a wired box in the official UI, copy the outgoing save fields into `BobbaWiredCache.put(id, presetWired)`.

On export, for uncached boxes: request config through the same path the official wired UI uses when you double-click a box. Prefer:

1. Session/wired manager “get furni data” already in memory
2. Send `Open` **and suppress the window** if the client has a flag
3. Last resort: Open and immediately close the wired window (worse UX)

Do **not** block `WiredFurniAction` packets — we are not G-Earth. If Open always pops UI, fetch one-by-one with a “retrieving wired 3/40” HUD and let the window flash, or skip wired with a warning.

**Variables:** after boxes, request all-variables diff (or read wired variable store) and fill `variables_map` name→id.

### 7.4 Availability (Phase 2)

```
need[className] = count in preset.furniture
have[className] = count of inventory floor items with that typeId
missing = need - have  (if > 0)
```

Post-config: if `glowball[0]` maps to existing room id `12345`, decrement need for that class and add `realFurniIdMap[presetId]=12345`, **remove** that furni from the place list (G-Presets `applyPostConfig`).

If any missing and `AllowIncomplete` is false → refuse import.

### 7.5 Import queue (Phase 3)

Build an array of steps. Runner executes sequentially. `cancel` flag checked before each step.

**Step types**

| Type | Action | Wait |
|---|---|---|
| `PLACE` | `PlaceObject` from next inventory item of typeId at (x,y,rot) | until new id at that cell **or** timeout |
| `MOVE_STACK` | `MoveObject` stack tile | short delay `RateMoveMs` |
| `SET_HEIGHT` | `SetCustomStackingHeight(stackId, z*100 + floorOffset*100)` | `RateMoveMs` |
| `MOVE` | `MoveObject(realId, x, y, rot)` | `RateMoveMs` |
| `SET_STATE_VAR` | `WiredSetObjectVariableValue` if rights | feedback timeout |
| `TOGGLE` | move to empty tile, `UseFurniture` until state matches or 20 tries, move back | per try |
| `SET_ADS` | `SetObjectData` 8 fields | 100 ms |
| `SAVE_WIRED` | remap ids, send Update* | WiredSaveSuccess or 5s, retry 2 |
| `RESTORE_STACK` | move stack tiles home | — |

**Order (G-Presets):**

1. Unstackables → `PLACE` at **final** `root+rel` with final rotation
2. Move main stack tile to `findStackTileLocation()` (empty corner, not overlay tile, not wired on first two cells)
3. Stackables → `PLACE` onto stack tile (triggers at `stackX+1` so they are not stacked on other wired)
4. Wait until all expected `PLACE` ids mapped (`presetId → realId`) via `x|y|typeId` queue
5. Ads
6. Wired (Phase 4) — for snapshot bindings: MOVE/TOGGLE bound furni into recorded pose, SAVE_WIRED, undo MOVE
7. For each stackable (triggers last): optional state, then MOVE to final with SET_HEIGHT
8. Second pass: anything still on stack tile or empty tile
9. Restore stack tiles
10. HUD Done

**Id map:** when placing, push `presetId` onto `expect[x|y|typeId]`. After place, poll snapshot until a new hotel id appears on that tile with that type, pop the queue, `realIds[presetId]=hotelId`.

**Inventory cache:** `typeId → queue of inventory item ids`. Pop on PLACE. If empty and not incomplete → abort.

**Empty tile:** user-picked unoccupied tile next to avatar (G-Presets recommendation). Used only for `UseFurniture` toggles when variable-set is unavailable.

**Root:** overlay click or `:ip x,y`. `heightOffset = lowestFloorPoint(room, preset, root)`.

### 7.6 Rate limits

| Setting | Default | Used on |
|---|---|---|
| place | 150 ms | after PLACE composer, **plus** wait-for-add |
| move | 60 ms | MOVE / SET_HEIGHT |
| wired | 300 ms min gap per box type | G-Presets `latestConditionSave` etc. |
| add-wait timeout | 8 × 500 ms | if expect map still non-empty |

Never fire 50 PlaceObject in one frame.

---

## 8. Commands

Implement in `LilithCustoms.ParseChatInput`. Block from hotel chat (do not send the colon command as speech).

| Input | Mode needed | Action |
|---|---|---|
| `:presets` `:preset` | any | toggle `displayPresets` |
| `:ep` `:exportpreset` | IDLE | `startExportSelection` |
| `:ep all` `:exportpreset all` | IDLE | `startExportAll` (skip corners, go to name) |
| `:ip` `:importpreset` | IDLE + preset selected + builder on | `startImport` |
| `:ip 0,0` | same | `startImportAt(0,0)` skip root overlay |
| `:abort` `:a` | any non-IDLE | `abort` |

Helper Extra: action `"presets"` next to Trax, label `helper.action.presets`.

---

## 9. Window layout (Phase 0 polish)

`VIEW_W = 420`, `VIEW_H = 448`. Frame XML `432 × 484`. Margins 6/30/6/6. Caption from `presets.title`. `color="0xff000000"`. Flags: `setParamFlag(257,false)`, `setParamFlag(32768,true)` so drag is header-only.

```
y=8     tabs: Library | Export | Import | Settings     (x=12, gap=4)
y=38    LIBRARY:
        list  x=12 w=240 h=220
        preview x=260 w=148 h=220
y=268   buttons 2×2: Export selection, Import here, Check items, Open folder
y=314   readiness: Room · Inventory · Stack · Rights   (dot + label)
y=338   log  x=12 w=396 h=96  (last 5 lines, Ubuntu 10, #D8D4D3)
```

**Export tab:** checkbox Include wired, button Whole room, name field (shown during EXPORT_NAME too).  
**Import tab:** selected name, W×H, Start, Abort, hint for empty tile. Disabled unless `BuilderEnabled` and readiness green.  
**Settings tab:** stack tile classname (text or later dropdown), place-ms stepper, allow incomplete, builder tools toggle, post-config two fields (furni name, existing id) + add/remove.

Fonts: `"Ubuntu"` / `"Ubuntu bold"`, `embedFonts=true`, `antiAliasType=advanced`, `gridFitType=pixel`. Colors: text `#FFFFFF` / `#D8D4D3` / `#6E6E6E`, green `#31A342`. `smoothing=false`, `pixelSnapping.ALWAYS`.

Readiness:

| Dot | Green | Amber | Red |
|---|---|---|---|
| Room | `inRoom` | session entering | no session |
| Inventory | furni model loaded | request in flight | never requested |
| Stack | item of configured class in room | — | missing (import only; Library can stay grey) |
| Rights | can move; if export-wired, can modify wired | — | no rights |

---

## 10. Overlay + HUD

**Overlay bar** (stage or room layer, not inside the Habbo frame): 280×22, centered bottom. Text from i18n. Esc aborts.

**HUD** during `IMPORT_RUNNING`: 280×48, top-center. Label + bar + Abort. Stages: Unstackables → Stackables → Ads → Wired → Move → Done. `view.setHud(stageKey, current, total)`.

While running: disable Library/Import buttons; keep Abort. Do not rely only on `setMouseEventsDisabledRect` for the whole room — also ignore View clicks that would start a second import.

---

## 11. JSON fixture (commit after S0)

`docs/fixtures/presets/minimal-glow.json` — used to test the parser without a hotel:

```json
{
  "furni": [
    {
      "id": 1,
      "className": "val11_floor",
      "name": "val11_floor[0]",
      "location": { "x": 0, "y": 0, "z": 0.0 },
      "rotation": 0
    },
    {
      "id": 2,
      "className": "glowball",
      "name": "glowball[0]",
      "location": { "x": 1, "y": 0, "z": 0.0 },
      "rotation": 2,
      "state": "1"
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

Parser must load this. Library shows `2 furni · 0 wired · 2×1`.

Also copy one real G-Presets file from their repo (Bopper) into `docs/fixtures/presets/gpresets-bopper.json` once export exists, to test unknown-key ignore.

---

## 12. i18n keys

Add to `en.json`, `pt-BR.json`, `es.json`. English values below; translate the others in the same PR as the keys.

```
presets.title = Presets
presets.tab.library = Library
presets.tab.export = Export
presets.tab.import = Import
presets.tab.settings = Settings
presets.action.exportSelection = Export selection
presets.action.exportAll = Whole room
presets.action.importHere = Import here
presets.action.checkItems = Check items
presets.action.openFolder = Open folder
presets.action.abort = Abort
presets.action.save = Save
presets.action.dump = Dump room
presets.ready.room = Room
presets.ready.inventory = Inventory
presets.ready.stackTile = Stack tile
presets.ready.rights = Rights
presets.overlay.corner1 = Click first corner
presets.overlay.corner2 = Click opposite corner · {0} × {1}
presets.overlay.name = Name this preset
presets.overlay.emptyTile = Click an empty tile (for state toggles)
presets.overlay.root = Click where (0,0) should land
presets.hud.unstackables = Placing unstackables
presets.hud.stackables = Placing furniture
presets.hud.ads = Setting backgrounds
presets.hud.wired = Setting up wired
presets.hud.move = Moving into place
presets.hud.done = Done
presets.log.exported = Exported "{0}"
presets.log.imported = Imported "{0}"
presets.log.aborted = Aborted
presets.log.missingItems = Missing furniture — check items
presets.log.noStackTile = Place a stack tile first
presets.log.noPreset = Select a preset first
presets.log.noRoom = Enter a room first
presets.log.busy = Finish or abort first
presets.settings.includeWired = Include wired
presets.settings.allowIncomplete = Allow incomplete builds
presets.settings.builder = Enable builder import
presets.settings.stackClass = Stack tile class
presets.settings.placeMs = Place delay (ms)
presets.preview.dim = {0} × {1}
presets.preview.counts = {0} furni · {1} wired
presets.preview.ready = Ready to import
presets.preview.notReady = Not ready
helper.action.presets = Presets
```

`BobbaI18n.t(key, fallback)` — always pass English fallback.

Interpolation: if `t` has no `{0}`, format in View (`split`/`replace`). Keep it dumb.

---

## 13. Phase Done checklists

### Phase 0 — Shell

- [x] S0 Done
- [x] Tabs render; Library lists `presets/*.json`
- [x] Open folder reveals the directory
- [x] Readiness Room dot works
- [x] Tile picker logs one `x,y` (even without draw)
- [x] i18n keys exist in 3 locales
- [x] Helper Extra opens the window

### Phase 1 — Export (first public slice)

- [x] Two-click rect overlay with W×H
- [x] Name field rejects illegal characters
- [x] JSON has relative coords and `className[n]`
- [ ] `:ep all` exports whole room
- [ ] G-Presets fixture loads
- [ ] Wired cache fills when the user saves a box
- [ ] Unknown wired: fetch or clear warning; no 200 stacked wired windows
- [ ] `ads_background` map exported when present

### Phase 2 — Availability

- [ ] Check items lists missing classNames
- [ ] Inventory request if not loaded (amber dot)
- [ ] Post-config removes a furni from the place list
- [ ] Incomplete flag respected

### Phase 3 — Geometry import

- [ ] Builder toggle required
- [ ] Stack tile required
- [ ] 20-item floor-only preset at `:ip 0,5` matches layout and heights
- [ ] Abort mid-place stops further composers
- [ ] HUD progress
- [ ] Stack tiles restored

### Phase 4 — Wired

- [ ] Self-exported 3-box circuit still triggers after import
- [ ] Snapshot binding pose/restore
- [ ] Variable rename map
- [ ] Missing wired skipped if incomplete on

### Phase 5 — Share (later)

- [ ] New BobbaWireCodec ids (next free ≥ 80) list/get/put JSON
- [ ] Hotel-scoped; no SSO in payload
- [ ] Library section This device | Bobba

---

## 14. Suggested PR / commit slices

1. `presets: spike window + room dump JSON`
2. `presets: library, store, i18n, helper extra`
3. `presets: tile overlay + rectangle export`
4. `presets: wired cache + G-Presets JSON parity`
5. `presets: availability + post-config`
6. `presets: import queue geometry`
7. `presets: wired apply + HUD polish`
8. `presets: sidecar share` (optional)

Do not mix Trax/Helper unrelated edits.

---

## 15. Test plan (manual, ADL)

| # | Setup | Expect |
|---|---|---|
| T1 | Empty room, `:presets`, Dump | `_debug.json` exists, 0 furni OK |
| T2 | Place 3 chairs in an L, export selection | JSON 3 furni, relative 0,0 origin |
| T3 | Reload client, Library | Same names |
| T4 | Load `minimal-glow.json` | Preview 2×1 |
| T5 | Export with wired off, wired boxes in rect | `wired` arrays empty |
| T6 | Save a trigger in official UI, export | trigger `options` non-empty |
| T7 | Check items without inventory open | Amber then list |
| T8 | Import with builder off | Button disabled + log |
| T9 | Import 2 chairs with stack tile | Land at root, abort works on 2nd place |
| T10 | Leave room during export | Reset, no throw |

Log failures to `bobba_debug.log` (`Logger.as`).

---

## 16. Risks and probes

| Risk | Probe | Fallback |
|---|---|---|
| `getRoomObjectCount` missing | Log `roomEngine` methods in ADL | Iterate known id range / room instance furni map |
| Tile click not exposed | Search RoomObject mouse events | Temporary: pick via walking then `:ep mark` **only for S0**, not ship |
| PlaceObject string vs ints | Read composer ctor | Match official inventory drop |
| Z is string in protocol | Read MoveObject | Send as client does |
| Wired Open always shows UI | Try one box | Export wired = opt-in; warn |
| FFDec merge too large | Watch inject delta / VerifyError | Split later phases; keep View drawing thin |
| Stack tile class differs per hotel | Setting + auto-detect `tile_stackmagic*` | User picks from items in room |

---

## 17. Out of scope reminders

- Wall items, BC warehouse, autodonate
- Marketplace / paid presets
- Parsing G-Earth capture files other than G-Presets JSON
- Server-side paste (does not exist)
- Changing hotel protocol
- Public “official Bobba” endorsement of ToS-grey import — keep behind **Enable builder import**

---

## 18. Appendix — G-Presets behaviour we copy

Export: rectangle → collect → clip wired selections → remap ids → names → JSON. Wired from live saves + Open-fetch. Bindings for match-to-snapshot family.

Import: availability → empty tile → root → unstackables in place → stack dump → ads → wired (pose/save/undo) → move+state → restore tiles.

We **replace:** packet `FloorState`, `MoveAvatar` picker, `Thread.sleep` as the only wait, JavaFX UI, G-Earth intercept/block.

---

## 19. Appendix — first code to write (S0 file list)

Create in this order so merge compiles:

1. `BobbaPresetFurni.as`
2. `BobbaPresetConfig.as` (empty wired)
3. `BobbaPresetStore.as`
4. `BobbaRoomSnapshot.as` (best-effort iterate; log errors)
5. `BobbaPresetsController.as` (`dumpDebug` only)
6. `BobbaPresetsView.as` (title + dump button)
7. `BobbaPresetsEditor.as` (Helper clone)
8. Patch window manager + LilithCustoms + manifest
9. Inject + ADL + `:presets`
