# HabboAirBobba

**Bobba Client** — playable AIR client for [Bobba Packet](https://github.com/Bobba-Packet/BobbaPacket), launched as **AirBobba** from the [Bobba Launcher](https://github.com/Bobba-Packet/launcher).

Fork lineage: [HabboAirPlus](https://github.com/LilithRainbows/HabboAirPlus). Edited as an AIR SWF via [JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler).

**License:** GPL-3.0 (Bobba Packet–owned packaging/code). Upstream AirPlus keeps its original licenses.

> Community project. Not affiliated with Sulake.

| | |
|---|---|
| Org | https://github.com/Bobba-Packet |
| Repo | https://github.com/Bobba-Packet/HabboAirBobba |
| Local (typical) | `D:\projetos\habbo\HabboAirBobba` |

AirPlus is the **base**, not the destination. Ecosystem features should live **outside** the SWF whenever possible.

---

## Contents

1. [Status & Alpha scope](#status--alpha-scope)
2. [Quick start](#quick-start)
3. [Sibling repos](#sibling-repos)
4. [Branding](#branding)
5. [Launch / install](#launch--install)
6. [Repo layout](#repo-layout)
7. [SWF workflow](#swf-workflow)
8. [Tools pipeline](#tools-pipeline)
9. [Patches](#patches)
10. [cleanswf workspace](#cleanswf-workspace)
11. [Bobba AS3 helpers](#bobba-as3-helpers)
12. [External assets (`brand-pack`)](#external-assets-brand-pack)
13. [Client assets (`local_include`)](#client-assets-local_include)
14. [Illumina Dark atlas](#illumina-dark-atlas)
15. [Custom window guide](#custom-window-guide)
16. [AirPlus commands → settings UI](#airplus-commands--settings-ui)
17. [License, status, agent agreements](#license-status-agent-agreements)

---

## Status & Alpha scope

**Phase:** Fase 4 — Alpha. Goal: first release that builds/packages from this repo.

**In scope:** branding, repo structure, build/export/package, launcher artifacts, license hygiene.

**Out of scope:** new gameplay / command-soup expansions, in-SWF widgets/SDK, backend auth (Fase 5), full rewrite (Nitro), private hotel product.

**Success:** branded client runs with `Habbo.exe -server <id> -ticket <sso>`, and Bobba Launcher can Install → Play **AirBobba**.

**Landed:** baseline `HabboAir.swf`, FFDec export in `cleanswf/scripts/`, Bobba helpers (`Logger.as`, `utils/bobba/`), inject/merge/debug/package tooling.

**Still needed:** pin AirPlus/SWF version in docs, finish brand imports, first packaged `dist/` the launcher can install, enable launcher `AirBobba` once artifacts ship.

---

## Quick start

```powershell
# Place AirPlus HabboAir.swf at repo root; export/decompile into cleanswf\scripts\

powershell -ExecutionPolicy Bypass -File tools\inject-scripts.ps1
tools\update-and-debug.bat
powershell -ExecutionPolicy Bypass -File tools\package-client.ps1
```

---

## Sibling repos

| Repo | Role |
|---|---|
| [BobbaPacket](https://github.com/Bobba-Packet/BobbaPacket) | Monorepo: vision, brand, landing (`website/`), docs |
| [launcher](https://github.com/Bobba-Packet/launcher) | Tauri app — Classic · AirPlus · **AirBobba** |
| [api](https://github.com/Bobba-Packet/api) | Backend (later) |
| [widgets](https://github.com/Bobba-Packet/widgets) / [sdk](https://github.com/Bobba-Packet/sdk) / [homes](https://github.com/Bobba-Packet/homes) | Ecosystem after client Alpha |

Brand assets (canonical): monorepo `brand/logo/` — especially `logo-bobba-client-*.svg` and `logo-icon.svg`. Guide: `docs/BRAND.md`. Vision: `docs/PROJECT_VISION.md`.

**Local SWF workflow reference:** `D:\projetos\habbo\traxmachine`.

---

## Branding

| Token | Value |
|---|---|
| Accent | `#138A36` |
| Foreground | `#EAE6E5` |
| Background | `#12130F` |

- Product chrome / wordmark: **Bobba Client** (`logo-bobba-client-*`).
- Compact ecosystem mark: `logo-icon.svg`.
- Do **not** present Sulake/Habbo official logos as this project’s identity.
- Habbo pixel art is fine as nostalgia accents, not as the primary brand.
- Do not recolor logos outside the palette; no generic glow/shadow treatments.

---

## Launch / install

- Install root (launcher): `%AppData%\packet.bobba.launcher\downloads\{client}\{version}\`
- Planned folder name: `airbobba`
- Launch: `Habbo.exe -server <hotelId> -ticket <ssoTicket>`
- Ticket usually arrives via clipboard (`habbo://` / `hhxx.…` SSO) — launcher captures it; no custom login UI for Alpha.

---

## Repo layout

```
HabboAirBobba/
  README.md                  # this file (all project docs)
  LICENSE
  tools/                     # inject, merge, package, ADL debug, tweakers
  patches/                   # manifest of scripts to stage + merge rules
  brand-pack/                # external runtime assets (not in SWF)
  client-assets/             # local_include placeholders + Illumina atlas
  cleanswf/                  # decompiled AS3 workspace (large; mostly gitignored)
  runtime/                   # ADL app root
  dist/                      # packaged AirBobba for the launcher
  HabboAir.swf               # pinned baseline (gitignored)
  HabboAir_bobba.swf         # inject output (gitignored)
  ffdec/                     # optional local FFDec (or use sibling)
```

---

## SWF workflow

Tooling under `tools/` is adapted from Traxmachine — the practical way to ship custom AS3 into HabboAirPlus without a full Flash Builder recompile.

### Mental model

| Layer | What | Where |
|---|---|---|
| Baseline SWF | Upstream AirPlus `HabboAir.swf` | Repo root (gitignored) |
| Decompiled tree | Full AS3 export from FFDec | `cleanswf/scripts/` |
| Patches we own | Edited `.as` + helpers | `cleanswf/` + `patches/` |
| Inject | FFDec `-importScript` | `tools/inject-scripts.ps1` → `HabboAir_bobba.swf` |
| External pack | Images/sounds **not** in SWF | `brand-pack/` → beside SWF at runtime |
| Runtime app dir | `File.applicationDirectory` | `runtime/` (ADL) or `dist/` |

**Critical:** FFDec CLI **cannot add new ABC class names**. New classes must be merged as **file-private** into an *existing* script (usually `HabboWindowManagerComponent.as`). See `tools/merge-helpers-into-script.ps1`.

**FFDec AS3 parser gotchas:**

- No `/** … */` JSDoc — importer treats `/` as `DIVIDE` (silent no-op with `-onerror ignore`; watch for **delta 0**).
- Prefer `//` line comments in staged `.as` files.
- Successful Logger inject grew the SWF by ~514 bytes (`11371167` → `11371681`).

**Asset resolve order** (proven in Trax):

1. `File.applicationDirectory / <path>`
2. `File.applicationDirectory / local_include / <path>`
3. Fallbacks under `applicationStorageDirectory`

**Gordon CDN placeholders are 404.** Ship `client-assets/local_include/` SWFs locally or you get `COMPONENT_EVENT_ERROR` after login. `ExternalInterface is not available` under ADL is normal.

### Inject flow

1. Backup `HabboAir.swf` → `HabboAir.swf.bak_*` (keeps last 3)
2. Deploy `brand-pack/` → `bobba/` and `local_include/bobba/`
3. Merge helpers into host (`patches/manifest.json` → `merge-helpers-into-script.ps1`)
4. Stage safe scripts → `tools/inject-staging/scripts/`
5. `ffdec-cli -air -onerror ignore -importScript HabboAir.swf HabboAir_bobba.swf <staging>`

### Do not reimport via FFDec

| Script | Failure if reimported |
|---|---|
| `IHabboWindowManagerComponent` | Interface slot breakage (`#1069 registerHintWindow`) |
| `EventDispatcherWrapper` / `Core` | Breaks `IEventDispatcher` (`#1034`) |

Add new public methods on the **implementation** only, not on the interface.

### Runtime pattern (reuse)

```
Chat command (:bobba / :traxmachine)
  → LilithCustoms.ParseChatInput
  → HabboWindowManagerComponent.displayXxx()
  → XxxEditor builds Habbo window from XML
  → Assets from disk (File + Loader)
  → Sprite UI in display_object_wrapper
```

Branding-only Alpha may only need string/asset swaps. Prefer launcher/widgets over growing `LilithCustoms`.

### Debug loop

1. Inject → `HabboAir_bobba.swf`
2. Copy into `runtime/HabboAir.swf` + sync `brand-pack`
3. Run `adl.exe` with `tools/HabboAir-debug-app.xml`, app root = `runtime/`
4. Stacks: ADL console + optional `Logger` → `applicationStorageDirectory`

AIR SDK: `tools/config.ps1` (default `D:\SDKs\AIR\AIRSDK_51.2.2`). FFDec: local `ffdec/` or sibling Traxmachine.

### Traxmachine reference paths

| Path | Role |
|---|---|
| `traxmachine/tools/inject-traxmachine.ps1` | Original inject |
| `traxmachine/tools/merge-trax-into-hwm.ps1` | File-private merge |
| `traxmachine/tools/update-and-debug.bat` | Deploy + ADL |
| `traxmachine/cleanswf/scripts/.../utils/traxmachine/` | Feature AS3 (do not copy for Alpha) |
| `traxmachine/traxmachine-pack/` | External pack pattern |
| `traxmachine/ffdec/` | JPEXS CLI |

**Caution:** re-exporting all scripts from FFDec into `cleanswf/scripts/` overwrites Bobba-owned files (`Logger.as`, `utils/bobba/`). Export to a temp folder or restore helpers from git after a wipe.

---

## Tools pipeline

PowerShell / batch adapted from Traxmachine: inject AS3, keep assets external, debug under ADL, package for the launcher.

### Prerequisites

| Tool | Notes |
|---|---|
| **Java** | Required by FFDec |
| **FFDec CLI** | Local `ffdec\ffdec-cli.exe`, or `..\traxmachine\ffdec\` (see `config.ps1`) |
| **AIR SDK** | Default `D:\SDKs\AIR\AIRSDK_51.2.2` — override via `AIR_SDK_HOME` or `config.ps1` |
| **Baseline SWF** | AirPlus `HabboAir.swf` at repo root |
| **Decompiled tree** | FFDec-export into `cleanswf\scripts\` |

### Paths touched

| Path | Role |
|---|---|
| `HabboAir.swf` | Input baseline |
| `HabboAir_bobba.swf` | Inject output |
| `cleanswf\scripts\` | Edit AS3 here |
| `patches\manifest.json` | What to stage / merge |
| `brand-pack\` | External assets |
| `runtime\` | ADL app directory |
| `dist\airbobba\` | Packaged client for launcher |

Layout tweaker: `tools/bobba-helper-tweaker.html` (assets in `tools/bobba-helper-tweaker-assets/`). Polaroid tweaker: `tools/polaroid-tweaker.html`.

---

## Patches

`patches/manifest.json` tells `tools/inject-scripts.ps1` which `.as` files to feed FFDec.

1. Export/copy AirPlus tree into `cleanswf/scripts/`.
2. Edit scripts (branding, chrome, etc.).
3. List changed **existing** scripts in `manifest.json` → `stage`.
4. For **new** classes: keep under e.g. `utils/bobba/`, list in `merge.helpers`, set `merge.host`, include host in `stage`.
5. Run `tools/inject-scripts.ps1`.

| Safe (typical) | Unsafe (breaks inject) |
|---|---|
| `LilithCustoms.as` | `IHabboWindowManagerComponent.as` |
| `HabboWindowManagerComponent.as` (merged) | `EventDispatcherWrapper` / `Core` |
| `Logger.as` | Random mass reimports |

---

## cleanswf workspace

Export HabboAir.swf with FFDec (GUI: Export → scripts), or copy a known-good AirPlus tree.

```
cleanswf/scripts/
  Logger.as
  com/sulake/habbo/window/LilithCustoms.as
  com/sulake/habbo/window/HabboWindowManagerComponent.as
  com/sulake/habbo/window/utils/bobba/   ← Bobba-owned helpers
  ...
```

Large and mostly gitignored; keep Bobba-owned helpers tracked under `utils/bobba/`.

---

## Bobba AS3 helpers

Under `cleanswf/scripts/com/sulake/habbo/window/utils/bobba/`. **Not** injected as their own ABC classes — merge into a host:

1. List in `patches/manifest.json` → `merge.helpers`
2. Set `merge.host` (usually `HabboWindowManagerComponent.as`)
3. Include host in `stage[]`
4. Run `tools/inject-scripts.ps1`

| File | Role |
|---|---|
| `BobbaPack.as` | External pack path resolver (Trax `resolvePackFile` pattern) |
| `BobbaHelperEditor.as` / `BobbaHelperView.as` | Habbo frame + canvas Sprite for `:bobba` |

Opened via `HabboWindowManagerComponent.displayBobbaHelper()`. Full how-to: [Custom window guide](#custom-window-guide).

---

## External assets (`brand-pack`)

Deployed next to `HabboAir.swf` (not baked into the SWF):

```
<app>/bobba/...
<app>/local_include/bobba/...
```

| File | Use |
|---|---|
| `bg_pattern_darktile.png` | Dark tiled login/loading background |
| `bg_pattern_bobbaskulls1.gif` | Optional alternate pattern |
| `logo-bobba-client.png` | Centered logo on SSO + loading |
| `shadow.png` | Soft glow/shadow behind SSO logo |
| `splash_pictures_no_pixel.png` | Polaroid frame overlay (838×302 runtime) |
| `checkbox.png` | Toggle sheet **36×18** (2× **18×18**) |
| `bobba_clothes_btn.png` | Clothes button sheet **110×30** (2× **55×30**) |
| `bobba_clothes_hero.png` | Nickname bar hero BG when Clothes on (**485×109**) |
| `bobba-client-logo-splash.png` | Helper window logo |
| `bobba-flower.png` / `bobba-discord-btn.png` / `bobba-settings-btn.png` | Helper chrome |

**Sprite sheets** (Habbo-style horizontal 2-state): left = off, right = on. Crop with `frameWidth = image.width / 2`.

Also copy new PNGs into `client-assets/` when editing; `inject-scripts.ps1` redeploys `brand-pack` → `bobba`.

---

## Client assets (`local_include`)

AirPlus resolves room placeholders via `FileProxy.localFileExists` before Habbo CDN. As of 2026-07, Sulake’s gordon folder `flash-assets-PRODUCTION-202607161412-307606313/` **404s** these SWFs — ship them from `client-assets/local_include/`:

- `HabboRoomContent.swf`
- `PlaceHolderFurniture.swf`
- `PlaceHolderPet.swf`
- `PlaceHolderWallItem.swf`
- `SelectionArrow.swf`
- `TileCursor.swf`

`tools/update-and-debug.bat` and `tools/package-client.ps1` sync into `runtime/local_include/` and `dist/airbobba/local_include/`.

---

## Illumina Dark atlas

Source atlas: `cleanswf/scripts/_assets/2332_habbo_skin_illumina_dark_1_png.png` (243×137). Slices live in `client-assets/illumina-dark-atlas/` (plus `*_x8.png` nearest-neighbor previews). Export: `tools/export-illumina-dark-atlas.py`.

| Folder | What | Used for |
|--------|------|----------|
| `01_frame/` | 9-slice window chrome | Dark theme **frames** (style 200) |
| `02_button/` | 9-slice button chrome | Dark theme **buttons** / container_buttons |
| `03_border_and_header/` | 9-slice panel chrome | Dark **borders** AND **headers** (same pixels) |
| `04_extra_unreferenced/` | Extra button blocks | In atlas but **not** in current skin XMLs |

Illumina Dark = theme style **200** (`ThemeManager` / `habbo_element_description`):

- `frame` → `illumina_dark_skin_frame_xml` → **01_frame**
- `button` / `container_button` → **02_button**
- `border` / `header` → **03_border_and_header**
- Scrollbars use separate PNGs (`illumina_dark_scrollbar_*`)

```
[ frame 28x30 ] [ button 28x29 ] [ border/header 38x30 ]
                [ extra button y34 / y68 / y102 ]
```

See `_atlas_annotated_x3.png`. Skin XMLs: `2812_…frame…`, `1816_…button…`, `2733_…border…`, `2074_…header…`.

---

## Custom window guide

Pattern used for **Bobba Helper** (`:bobba`) and Trax Machine.

| Piece | Path |
|-------|------|
| Editor | `cleanswf/scripts/.../bobba/BobbaHelperEditor.as` |
| View | `…/bobba/BobbaHelperView.as` |
| Assets | `…/bobba/BobbaPack.as` |
| Open API | `HabboWindowManagerComponent.displayBobbaHelper()` |
| Chat hook | `LilithCustoms` → `:bobba` |
| Layout tweaker | `tools/bobba-helper-tweaker.html` |

### Architecture

```
Chat / toolbar / code
        │
        ▼
HabboWindowManagerComponent.displayXxx()
        │
        ▼
XxxEditor                          ← Habbo IFrameController (chrome, close, drag)
   └── display_object_wrapper
            └── XxxView : Sprite   ← your pixels, text, buttons
```

| Class | Job |
|-------|-----|
| **Editor** | `buildFromXML` frame, margins, procedure, host canvas, show/hide, dispose, room mouse block |
| **View** | Draw on black `Sprite`, load pack assets, toggles, buttons, fonts |

Custom pixel UI belongs in the View Sprite — do not build the whole UI as Sulake XML widgets unless you need native Habbo controls.

### Merge helpers into host

1. Put helpers under `cleanswf/scripts/.../utils/<pack>/`
2. In `patches/manifest.json`: host in `stage[]`, helpers in `merge.helpers`, `merge.host` set
3. Run `tools/inject-scripts.ps1`

Add `import …XxxEditor;` on the host. Re-export wipes helper folders — restore from git. Inject must **preserve the merged host** after staging clears.

### Editor checklist

XML skeleton:

```xml
<layout name="my_window" width="W" height="H" version="0.1">
  <window>
    <frame x="0" y="0" width="W" height="H" params="33025" style="1"
           name="my_frame" caption="Title" color="0xff000000">
      <children>
        <display_object_wrapper x="0" y="0" width="VIEW_W" height="VIEW_H"
          params="16" style="0" name="my_canvas"/>
      </children>
      <variables>
        <var key="margin_left" value="6" type="int"/>
        <var key="margin_top" value="30" type="int"/>
        <var key="margin_right" value="6" type="int"/>
        <var key="margin_bottom" value="6" type="int"/>
      </variables>
    </frame>
  </window>
</layout>
```

Size: `W = VIEW_W + 12`, `H = VIEW_H + 36` (typical margins 6/30/6/6). Keep XML and `VIEW_W`/`VIEW_H` in sync.

After `buildFromXML`:

```actionscript
_window = built as IFrameController;
_window.color = 0xff000000;
_window.margins.left = 6;
_window.margins.top = 30;
_window.margins.right = _window.width - 6;
_window.margins.bottom = _window.height - 6;
_window.procedure = windowProcedure;
_window.center();
_window.setParamFlag(257, false);     // not drag-from-content
_window.setParamFlag(32768, true);    // drag target = frame
_canvas = _window.findChildByName("my_canvas") as IDisplayObjectWrapperController;
_canvas.width = _window.content.width;
_canvas.height = _window.content.height;
_view = new XxxView(...);
_canvas.setDisplayObject(_view);
```

Close: `WME_CLICK` on `header_button_close` → `visible = false`. Singleton `displayMyWindow()` on window manager; dispose in `dispose()`.

### View checklist

Fill full canvas for hit area (`graphics.drawRect` black). Assets via `BobbaPack.resolveUrl("my-sprite.png")`.

**Pixel art:** `smoothing = false`, `pixelSnapping = ALWAYS`, integer scale only, whole-pixel `x`/`y`.

| Asset | Size | Notes |
|-------|------|-------|
| Logo splash | 124×108 | 1× unless you ship 2× |
| Checkbox sheet | 36×18 (2×18) | left=off, right=on |
| Flower | 35×93 | |
| Discord / settings | 300×26 (3×100×26) | normal / hover / click |

**Fonts:** `"Ubuntu"` / `"Ubuntu bold"` (do **not** set `fmt.bold = true` on bold face). Use `FontEnum.isEmbeddedFont`, `embedFonts = true`, `antiAliasType = "advanced"`, `gridFitType = "pixel"`. Fallback Verdana. Labels `mouseEnabled = false`.

**Toggles:** parent Sprite `buttonMode` + `useHandCursor`, `mouseChildren = false`; refresh on show. **3-state buttons:** `[normal | hover | click]` — ROLL_OVER/OUT, MOUSE_DOWN/UP, CLICK. Open URLs with `navigateToURL` / `HabboWebTools.navigateToURL`.

### Room mouse block

Filling the Sprite is **not** enough. Register frame rect:

```actionscript
_windowManager.roomEngine.setMouseEventsDisabledRect("my_window_key", rect);
// on hide / dispose:
_windowManager.roomEngine.removeMouseEventsDisabledRect("my_window_key");
```

Update on `WE_RELOCATED`, `WE_RESIZED`, `WME_UP`. Do **not** capture-phase `stopPropagation` on the View — kills child clicks.

### Chat wiring

1. Add `":mycommand"` to `AllowedCommands`
2. `ParseChatInput` → `_windowManager.displayMyWindow()`
3. Persist via `UpdateVariablesValues` / `SaveVariablesValues` if needed
4. Expose Get/Set toggles for the View

### New window recipe

1. Copy Editor + View → rename
2. Strip View to background + one text field; confirm open
3. Add to `merge.helpers`; add `displayXxx()` + dispose
4. Hook command; assets → `brand-pack/`
5. Room mouse block with unique key; inject and test

### Param cheat sheet

| Value | Meaning |
|-------|---------|
| `params="33025"` on frame | Standard interactive frame |
| `257` | Drag trigger — header on, content off |
| `32768` | Drag target — enable on frame |
| `params="16"` on canvas | Child clips to parent mouse region |
| DisplayObjectWrapper | Bounds hit-test (not alpha) |

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| New class missing / VerifyError | Helper not merged / host not preserved |
| Blank or old UI | Wrong SWF; or merge wiped |
| Blurry pixels | Fractional scale or `smoothing = true` |
| Invisible text | Wrong font / `embedFonts` without face |
| Bold wrong | Used `bold=true` instead of `"Ubuntu bold"` |
| Click walks avatar | Missing `setMouseEventsDisabledRect` |
| Buttons dead | Capture-phase `stopPropagation` on View |
| Asset 404 | File not in `bobba/` next to running SWF |
| Wrong size | XML frame ≠ `VIEW_W/H` + margins |

Layout knobs live as named constants at the top of `BobbaHelperView.as`. Tweaker: under `file://`, never use canvas `toDataURL()` on local images (taints) — use CSS sprite clipping or HTTP.

---

## AirPlus commands → settings UI

Source: `LilithCustoms.as`. In-client list: HabboPage `chat/commands` (Base64 `AirPlusCommandsHabboPageBase64`). Persistence: `SharedObject.getLocal("HabboAirPlus", "/")` via `UpdateVariablesValues`.

Official Habbo chat (`:dance`, `:kick`, …) stays chat-only unless noted. Prefer implementing this UI **outside** the SWF (launcher / widget) writing the same SharedObject keys — avoid growing `ParseChatInput`.

### UI shell

```
┌─────────────────────────────────────────────────────────────┐
│  Client settings                              [Reset] [×]   │
├──────────────┬──────────────────────────────────────────────┤
│ Appearance   │  Section title                               │
│ Chat         │  Short helper line                           │
│ Room         │  ─────────────────────────────────────────   │
│ Avatar       │  Label                    [control]          │
│ Controls     │  …                                           │
│ Hotkeys      │                                              │
│ Social       │                                              │
│ Tools        │                                              │
│ Advanced ⚠   │                                              │
│ About        │                                              │
└──────────────┴──────────────────────────────────────────────┘
```

| Rule | Detail |
|------|--------|
| Left nav | One active category |
| Rows | Label left, control right; optional muted caption |
| Chat aliases | Primary command; aliases as muted text |
| Live preview | Theme / blend / chat size update immediately |
| Footer | **Reset all** (`:resetvars`), **Import/Export** (`:solimp` / `:solexp`) |
| Risk | Amber badge; Advanced is default home for risky commands |

**Controls:** Toggle · Slider · Stepper · Color field · Segmented · Text field · Button · Danger button.

**Default landing:** Appearance (Bobba Alpha). Never land on Advanced.

### 1. Appearance

| Setting | Command(s) | Control | Default |
|---------|------------|---------|---------|
| Title bar color | `:color` | Color + presets | `#C13270` |
| Bottom bar color | `:barcolor` | Color + presets | `#751E4B` |
| Window blend | `:winblend` | Slider 0–1 | `1.0` |
| Bottom bar blend | `:barblend` | Slider 0–1 | `0.5` |
| Alt bottom bar | `:barstyle` | Toggle | off |
| Seasonal colors | `:seasonal` | Toggle | on |

### 2. Chat

**Visibility & size:** `:chatmute`, `:chatsize` (12–40), `:showbubbles`, `:spoofbubbles` `[own]`, `:chatcolor`, `:cmdcolor`, `:typing`, `:hideignoredbubble`.

**Mute filters:** `:mutepets`, `:mutebots`, `:mutecmd`.

**Ping:** `:pingbeforetext`, `:pingaftertext`, `:pingbubble`, `:pingsay`, `:ping`.

**Flood & alarm:** `:flood`, `:flooddelay`, `:chatalarm`.

**One-shot:** `:clearchat`, `:clearhist`.

### 3. Room & performance

| Setting | Command(s) | Control | Persist? |
|---------|------------|---------|----------|
| Backlight / room light | `:backlight` / `:roomlight` 0–255 | Slider | yes |
| Background color | `:bgcolor` H S L | HSL | yes |
| Forced FPS | `:fps` | Slider | yes |
| Unlock anim FPS | `:unlockfps` / `:fpsunlock` | Toggle | yes |
| Fractional zoom | `:zoomf` | Slider | yes |
| Zoom gestures | `:zoomgestures` | Toggle | yes |
| Click-through | `:playing` | Toggle | yes |
| Object / quest IDs | `:showids` / `:showquestsids` | Toggle | yes |
| Room rotate | `:rotate` | Toggle | session |
| Reset camera / show FPS | `:rescam` / `:showfps` | Button | — |

Camera aliases (`:cam` / `:camera` / `:zoom` / `:fs`) can be one **Open camera** button.

### 4. Avatar & looks

**Session:** `:figure`, `:clone`, `:dance` 0–4, `:handitem`, `:fx`, `:lightsaber`, `:laugh`, `:afk`, `:give` / `:pass` (⚠).

**Saved looks:** `:savelook`, `:uselook`, `:removelook`, `:showlooks`, `:clearlooks`.

**Hide filters:** `:hidefigures`, `:hidepoints` N.

### 5. Controls & interaction

`:infostand`, `:nodc` (allow double-click), `:dc`, `:shift` / `:swb`, `:ctrl`, `:walkblock`, `:tradeblock`, `:turnblock`, `:wcublock`, `:autoclick` + `:autoclickdelay`.

Target helpers (need selection): `:clickuser`, `:clickfurni`, `:usefurni`, `:movetofurni`.

### 6. Hotkeys

`:hkmode` (up/down), `:hkset`, `:f1`…`:f12`, `:hkshow` / `:showhk`, `:hkclear`.

### 7. Social

`:fon` 0–2, `:friendhl`, `:respect` (⚠), `:givegem` (⚠).

### 8. Tools

`:calendar`, `:linkevent`, `:safetybook`, `:habboway`, `:furnitech`, `:linkport` / `:portlink`, `:totem`, `:spawn`, `:caution`. Say/shout/whisper stay out of settings.

### 9. Advanced ⚠

`:adblock`, `:devwar` / `:stopdevwar`, `:showerrors`, `:crash`, `:aprilfools`, `:acceptquest`, `:solexp` / `:solimp`, `:resetvars`. Bury `:abctest` / `:playtest`.

### 10. About

`:about` / `:version`, `:commands`.

### Chat-only (do not duplicate in settings)

Emotes/movement, moderation/room ops, navigator/mail/news/chooser/screenshot/fullscreen, etc. Optional link to `habbopages/chat/commands?`.

### Persistence map (SharedObject)

`ShowAllChatBubbles`, `CustomChatSize`, `IsChatEnabled`, `InfoStandDisabled`, `ShowObjectsIds`, `TitleBarColor`, `BottomBarColor`, `WindowBlend`, `BottomBarBlend`, `BottomBarAltStyleEnabled`, `IsPlayingEnabled`, `UserCustomFx`, `AntiAfkModeActivated`, `PingBeforeText`, `PingAfterText`, `PingBubble`, `AnimationFpsUnlocked`, `DesiredFpsValue`, `RoomBackgroundColors`, `RoomLight`, `RoomBacklight`, `AdBlockActivated`, `ChatTypingEnabled`, `ShowCriticalErrors`, `ShowQuestsIds`, `SpoofBubbles`, `HotKeysDictionary`, `CommandInputColorHintActivated`, `ChatTextColorEnabled`, `FurniDoubleClickEnabled`, `ZoomGesturesEnabled`, `IsTurnBlockEnabled`, `IsWCUBlockEnabled`, `FriendHighlightEnabled`, `FriendOnlineNotification`, `ShiftWalkBlockEnabled`, `CtrlUseFurniOnSingleClickEnabled`, `HideIgnoredBubbleEnabled`, `SeasonalColorsEnabled`, `HotKeyPressMode`, `MutePetsEnabled`, `MuteBotsEnabled`, `MuteCommandsEnabled`, `DesiredRoomFractionalSize`, `ModCautionAlertsEnabled`, `SavedLooksDictionary`.

Session-only (`:rotate`, hide-figure filters, flood state) reset on room change / restart unless you add persistence.

---

## License, status, agent agreements

- **Bobba Packet–owned** code/packaging: **GPL-3.0** (`LICENSE`).
- Upstream AirPlus keeps original licenses; credit LilithRainbows / HabboAirPlus and pin the client/SWF version.
- Using **Bobba Packet** / **Bobba Client** names in forks requires org alignment — code freedom ≠ trademark freedom.

### Working agreements for agents

1. Prefer progressive disclosure: branding + build before features.
2. Keep AirPlus launch parity (same exe args, ticket model).
3. Do not invent a full AS3 rewrite unless requested.
4. Brand changes follow monorepo `docs/BRAND.md`.
5. Keep secrets and hotel SSO tickets out of git.
6. After packaging exists, wire launcher `AirBobba` — do not leave “coming soon”.
7. Prefer **external packs** over baking assets into the SWF.
8. Never FFDec-reimport interfaces / Core / EventDispatcher wrappers without a known-good reason.
9. Do not port Trax Machine gameplay into this repo for Alpha.

### Quick links

- Upstream: https://github.com/LilithRainbows/HabboAirPlus
- JPEXS: https://github.com/jindrapetrik/jpexs-decompiler
- Launcher (local): `D:\projetos\habbo\launcher`
- Monorepo (local): `D:\projetos\habbo\bobba-packet`
- Traxmachine (local): `D:\projetos\habbo\traxmachine`
