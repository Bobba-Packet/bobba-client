# Bobba Settings Window — Content Spec

Handoff document for design. This catalogues every user-configurable setting in the client
(AirPlus inherited + Bobba additions + vanilla Habbo) and organises them into 5 categories,
each split into topics.

This document defines **what goes where and what control type each setting needs**.
It does not define visual style, spacing, or colours — that is the designer's job.

Entry point: the Bobba Helper (`:bobba`) already renders a settings button whose click handler
is currently `null` (`BobbaHelperView.as:203`). That button opens this window.

---

## 1. What the designer needs to decide

The window needs **5 top-level categories**, each containing **2–5 topics**, each topic being a
titled group of rows. Category 3 (Quarto) is the largest at 21 settings, so whatever navigation
pattern is chosen has to survive a tab with five topic groups in it.

**Layout editor:** open [`tools/bobba-settings-tweaker.html`](../tools/bobba-settings-tweaker.html)
in a browser. It previews every category/topic/row from this spec, lets you tune canvas size,
sidebar, search bar, and row density, and exports AS3 constants + frame XML sizes for
`BobbaSettingsView` / `BobbaSettingsEditor`.

Working defaults baked into the tweaker (change freely):

- **Navigation**: left sidebar with 5 items
- **Scrolling**: content pane scrolls; sidebar stays fixed
- **Row density**: single-column rows (mixed control heights)
- **Dependent/disabled rows**: previewable muted state
- **Search**: optional top search field

---

## 2. Control vocabulary

Every setting below maps to one of these controls. Only two exist in the client today, so most of
these need art.

| Control | Exists? | Used for | Notes |
|---|---|---|---|
| Toggle (checkbox) | Yes — `checkbox.png`, 2-frame off/on sheet | Boolean on/off | Already sliced in `BobbaHelperView.as:478` |
| Sprite button | Yes — 3-frame normal/hover/click sheet | Actions | Pattern at `BobbaHelperView.as:247` |
| Slider | **New** | Bounded numbers (FPS, light, zoom, volume) | Needs track, fill, handle, and a live value readout |
| Stepper / number field | **New** | Precise numbers (chat size, delays) | Could substitute for slider where precision matters |
| Dropdown | **New** | Enums with 3+ options | Needs closed state, open list, hover, selected |
| Segmented control | **New** | Enums with 2–3 options | Cheaper alternative to a dropdown; good for on/all/off triples |
| Text input | **New** | Free strings (ping text, alarm word) | Needs focus and placeholder states |
| Colour picker | **New** | Title/bottom bar colours, room background | Needs a swatch, a hex field, and ideally presets |
| Key-capture row | **New** | Hotkey bindings | Listens for a keypress; needs "press a key…" and "bound" states |
| Managed list | **New** | Saved looks, hotkeys, word filter | Rows with add/remove; the most complex control here |

---

## 3. Status legend

Not every setting is equally ready. The status column tells you whether a row is safe to design as
a normal working control or whether it carries a caveat.

| Status | Meaning |
|---|---|
| `Ready` | Persisted in the `HabboAirPlus` SharedObject and fully wired to behaviour |
| `Session` | Behaviour works, but the value is **not saved** and resets on restart. Needs persistence added before shipping in a settings window |
| `Stub` | Persisted, appears in the UI, but **no behaviour is implemented yet** |
| `Server` | Vanilla Habbo setting, persisted server-side through a message composer — a separate subsystem from AirPlus |

Anything marked `Session` or `Stub` is an engineering task, not a design blocker. Design the row
normally; we'll flag at build time if one has to ship disabled.

---

# Category 1 — Cliente

Settings about the application shell itself, not about gameplay. 13 settings.

## 1.1 Aparência

Window chrome theming. Note the dependency: bottom bar blend does nothing unless the alternative
bar style is enabled, and the whole group is overridden while seasonal colours are active.

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Cor da barra de título | Colour picker | `#C13270` | Any hex; presets `classic`, `pink` | Ready | `TitleBarColor` |
| Cor da barra inferior | Colour picker | `#751E4B` | Any hex; presets `classic`, `pink` | Ready | `BottomBarColor` |
| Transparência da janela | Slider | `1.0` | `0.0`–`1.0` | Ready | `WindowBlend` |
| Transparência da barra inferior | Slider | `0.5` | `0.0`–`1.0` | Ready | `BottomBarBlend` |
| Estilo alternativo da barra inferior | Toggle | Off | — | Ready | `BottomBarAltStyleEnabled` |
| Cores sazonais | Toggle | **On** | — | Ready | `SeasonalColorsEnabled` |

Design notes:

- **Transparência da barra inferior** must render disabled unless *Estilo alternativo* is on.
- **Cores sazonais** overrides the two colour pickers while a season is active. The window should
  say so — an inline hint under the toggle is enough.
- Changing seasonal colours requires a client reload to take effect. Needs a "requires reload"
  affordance; several other settings share this (see 3.2 and 1.2).

## 1.2 Desempenho

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| FPS do cliente | Slider + value | `60` | Suggest `10`–`144` | Ready | `DesiredFpsValue` |
| Desbloquear FPS das animações | Toggle | Off | — | Ready | `AnimationFpsUnlocked` |
| Otimização em FPS baixo | Dropdown | `auto` | `auto` / on / off | Ready | `RoomDisplayLowFpsBoost` |
| Bloquear anúncios (MPU) | Toggle | Off | — | Ready | `AdBlockActivated` |

**Bloquear anúncios** requires a room reload to take effect.

## 1.3 Áudio

These three are vanilla Habbo settings, currently living in the me-menu's sound panel. Pulling them
into this window means the user has one place for all audio instead of two.

| Label (pt-BR) | Control | Default | Range | Status | Source |
|---|---|---|---|---|---|
| Volume da interface | Slider | `0` | `0`–`100` | Server | `genericVolume` |
| Volume dos mobis | Slider | `100` | `0`–`100` | Server | `furniVolume` |
| Volume das músicas (Trax) | Slider | `100` | `0`–`100` | Server | `traxVolume` |

Note the interface volume default is **0** (muted) in the current client — worth surfacing rather
than hiding, since users often don't realise UI sound exists.

---

# Category 2 — Chat

18 settings. The largest cluster of everyday-use toggles, so this tab probably deserves the most
design attention.

## 2.1 Aparência do chat

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Tamanho da fonte do chat | Slider + value | `12` | `12`–`40` | Ready | `CustomChatSize` |
| Largura do balão | Segmented | Normal | Largo / Normal / Fino | Server | `chat_bubble_width` |
| Modo do chat | Segmented | Livre | Livre / Linha a linha | Server | `chat_mode` |
| Velocidade de rolagem | Segmented | Normal | Rápida / Normal / Lenta | Server | `chat_scroll_speed` |

A live preview bubble in this topic would be genuinely useful — four settings here all affect the
same visual result, and users currently have to guess.

## 2.2 Balões

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Mostrar todos os estilos de balão | Toggle | Off | — | Ready | `ShowAllChatBubbles` |
| Forçar estilo de balão | Dropdown | Desativado | Desativado / Meus balões / Todos | Ready | `SpoofBubbles` |
| Cor de texto personalizada | Toggle | Off | — | Ready | `ChatTextColorEnabled` |
| Indicador de digitação | Toggle | **On** | — | Ready | `ChatTypingEnabled` |

**Forçar estilo de balão** stores an empty string for off, `own` for the user's own bubbles, `all`
for everyone. If design wants a bubble-style **picker** rather than a scope selector, that is a
bigger change — flag it and we'll scope it.

## 2.3 Silenciar e filtrar

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Silenciar chat do quarto | Toggle | Off (chat on) | — | Ready | `IsChatEnabled` |
| Silenciar pets | Toggle | Off | — | Ready | `MutePetsEnabled` |
| Silenciar bots | Toggle | Off | — | Ready | `MuteBotsEnabled` |
| Silenciar comandos | Toggle | Off | — | Ready | `MuteCommandsEnabled` |
| Ocultar balões de ignorados | Toggle | Off | — | Ready | `HideIgnoredBubbleEnabled` |
| Filtro de palavras | Managed list | Empty | User-defined strings | Server | Word filter |

Careful with **Silenciar chat do quarto**: the underlying variable is `IsChatEnabled` and defaults
to `true`, so the toggle is **inverted** relative to the stored value. Label it as the mute action
(matching the `:chatmute` command) and let the implementation handle the inversion.

**Filtro de palavras** is a full list-management UI, not a row. It may deserve its own sub-screen.

## 2.4 Entrada e comandos

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Destaque de cor e autocompletar comandos | Toggle | **On** | — | Ready | `CommandInputColorHintActivated` |
| Palavra de alerta sonoro | Text input | Empty | Any string | **Session** | `ChatAlarmText` |
| Texto de flood | Text input | Empty | Any string | **Session** | `FloodText` |
| Intervalo do flood | Stepper | `1000` ms | Suggest `250`–`10000` | **Session** | `FloodTimer.delay` |

All three flood/alarm settings currently reset on restart. They need to be added to the persistence
registry before they belong in a settings window — design them as normal rows and we'll handle it.

---

# Category 3 — Quarto

21 settings, the biggest category. Five topics. This is the tab most likely to need scrolling.

## 3.1 Renderização e cores

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Luz do quarto | Slider + off state | Off (`-1`) | `0`–`255`, or off | Ready | `RoomLight` |
| Luz de fundo | Slider + off state | Off (`-1`) | `0`–`255`, or off | Ready | `RoomBacklight` |
| Cor de fundo do quarto | Colour picker (HSL) | Off (`null`) | Hue / Saturation / Lightness | Ready | `RoomBackgroundColors` |

All three have a meaningful **off** state distinct from any value in range (`-1` and `null`). The
control needs a way to express "not overriding" — a toggle beside the slider, or an off position at
the far left of the track.

**Cor de fundo do quarto** is HSL, not hex, unlike the chrome colours in 1.1. Either give it three
sliders or a picker that converts.

## 3.2 Zoom e câmera

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Zoom fracionado | Slider | `1` | Suggest `0.5`–`2.0` | Ready | `DesiredRoomFractionalSize` |
| Gestos de zoom | Toggle | Off | — | Ready | `ZoomGesturesEnabled` |
| Desativar câmera seguindo o usuário | Toggle | Off | — | Server | `disable_room_camera_follow` |

**Gestos de zoom** requires a room reload to take effect.

## 3.3 Mobis

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Duplo clique em mobis | Toggle | **On** | — | Ready | `FurniDoubleClickEnabled` |
| Ctrl para usar mobi com um clique | Toggle | Off | — | Ready | `CtrlUseFurniOnSingleClickEnabled` |
| Usar mobi com um clique | Toggle | Off | — | **Session** | `UseFurniOnSingleClickEnabled` |
| Mover item de parede | Toggle | Off | — | Ready | `BobbaMoveWallItemEnabled` |
| Auto drop | Toggle | Off | — | Ready | `AutoDropEnabled` |
| Manter direção | Toggle | Off | — | Ready | `MaintainDirectionEnabled` |
| Autoclique | Toggle | Off | — | **Session** | `ObjectHighlighterEnabled` |
| Intervalo do autoclique | Stepper | `200` ms | Suggest `50`–`5000` | **Session** | `AutoClickTimer.delay` |

Three settings here overlap conceptually (double click, ctrl+single click, plain single click) and
partly contradict each other. Design should group them tightly, and it's worth considering
collapsing them into one segmented "Como usar mobis" control. Flag if you want that — it changes
the underlying variables.

**Intervalo do autoclique** should render disabled unless *Autoclique* is on.

## 3.4 Bloqueios

Protective toggles that stop accidental or unwanted actions. This is a coherent group and probably
the easiest topic to design — six uniform checkboxes.

| Label (pt-BR) | Control | Default | Status | Variable |
|---|---|---|---|---|
| Modo click-through | Toggle | Off | Ready | `IsPlayingEnabled` |
| Bloquear giro do avatar | Toggle | Off | Ready | `IsTurnBlockEnabled` |
| Bloquear WiredClickUser | Toggle | Off | Ready | `IsWCUBlockEnabled` |
| Shift para bloquear caminhada | Toggle | Off | Ready | `ShiftWalkBlockEnabled` |
| Bloquear caminhada | Toggle | Off (walk on) | **Session** | `WalkEnabled` |
| Bloquear trocas | Toggle | Off (trade on) | **Session** | `TradeEnabled` |

The last two are inverted like `IsChatEnabled` — stored as "enabled", presented as "blocked".

## 3.5 Sobreposições

| Label (pt-BR) | Control | Default | Status | Variable |
|---|---|---|---|---|
| Ocultar infostand | Toggle | Off | Ready | `InfoStandDisabled` |
| Mostrar IDs dos objetos | Toggle | Off | Ready | `ShowObjectsIds` |
| Mostrar IDs das missões | Toggle | Off | Ready | `ShowQuestsIds` |

---

# Category 4 — Avatar e Social

11 settings.

## 4.1 Avatar

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Efeito (FX) personalizado | Dropdown or number field | `0` (nenhum) | Effect IDs | Ready | `UserCustomFx` |
| Anti AFK | Toggle | Off | — | Ready | `AntiAfkModeActivated` |
| Visuais salvos | Managed list | Empty | Named figure strings | Ready | `SavedLooksDictionary` |

**Efeito personalizado** is stored as a raw numeric effect ID. A dropdown would need a curated
name-to-ID list that doesn't exist yet; a number field ships sooner. Designer's call — if you want
a visual effect picker, that's a separate piece of work worth scoping on its own.

**Visuais salvos** is a named list with save/apply/remove actions. Like the word filter, it may want
its own sub-screen rather than a row.

## 4.2 Amigos

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Destacar entrada de amigos | Toggle | **On** | — | Ready | `FriendHighlightEnabled` |
| Notificar amigo online | Segmented | Só relacionamentos | Desativado / Todos / Só relacionamentos | Ready | `FriendOnlineNotification` |

`FriendOnlineNotification` stores `0` / `1` / `2` respectively.

## 4.3 Notificações e privacidade

| Label (pt-BR) | Control | Default | Status | Source |
|---|---|---|---|---|
| Alertas de moderação | Toggle | **On** | Ready | `ModCautionAlertsEnabled` |
| Ignorar convites de quarto | Toggle | Off | Server | `ignore_room_invites` |
| Desativar sussurro de wired | Toggle | Off | Server | `wiredWhisperDisabled` |

## 4.4 Extras Bobba

Fork-specific features.

| Label (pt-BR) | Control | Default | Status | Variable |
|---|---|---|---|---|
| Chat em grupo | Toggle | Off | **Stub** | `BobbaGroupChatEnabled` |
| Sussurro em grupo | Toggle | Off | Ready | `BobbaGroupWhisperEnabled` |
| Desativar 67 | Toggle | Off | Ready | `BobbaDisable67Enabled` |
| Desativar Habbicons | Toggle | Off | Ready | `BobbaDisableHabbiconsEnabled` |
| Ver visuais Bobba | Toggle | **On** | Ready | `BobbaLooksEnabled` |

`BobbaDisable67Enabled` / `:disable67` hides the special `:67` bubble.  
`BobbaDisableHabbiconsEnabled` / `:disablehabbicons` hides room Habbicon stickers from other users.  
`BobbaLooksEnabled` gates the avatar-editor **Bobba Clothes** button and DevWar (`:devwar`). When on, the button opens a secondary unlocked wardrobe (instance 3) with the Bobba Clothes hero behind the nickname. Closing that editor disposes it to free RAM while keeping any look the user saved (`BobbaSavedFigure`). Turning the toggle off stops DevWar, unloads Bobba Clothes, and reverts the avatar to its original session figure.

`BobbaGroupWhisperEnabled` gates avatar-menu **Sussurro em grupo** and `:group` / `:grupo` room whisper (Bobba packets 60/61). Recipient list is per-room and clears on room enter.

`BobbaGroupChatEnabled` still saves/restores with **no gate behaviour wired yet** (`:groupchat` opens regardless).

---

# Category 5 — Avançado

11 settings. Power-user territory: hotkeys, the ping widget, debug output, and data management.

## 5.1 Atalhos

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Atalhos de teclado | Managed list + key capture | Empty | F1–F12 mapped to chat text | Ready | `HotKeysDictionary` |
| Modo de acionamento | Segmented | Ao soltar | Ao soltar / Ao pressionar | Ready | `HotKeyPressMode` |

**Atalhos de teclado** is the most complex control in the whole window: a list of key-to-text
bindings where each row needs a key display, an editable text field, and a remove action, plus an
add flow that captures a keypress. Consider a dedicated sub-screen.

## 5.2 Ping

| Label (pt-BR) | Control | Default | Range / options | Status | Variable |
|---|---|---|---|---|---|
| Texto antes do ping | Text input | `"Ping: "` | Any string | Ready | `PingBeforeText` |
| Texto depois do ping | Text input | Empty | Any string | Ready | `PingAfterText` |
| Estilo do balão do ping | Dropdown | `auto` | `auto` or a bubble style ID | Ready | `PingBubble` |
| Dizer ping publicamente | Toggle | Off | — | **Session** | `PingSay` |

A live preview of the assembled ping string ("Ping: 42ms") would make the two text fields
self-explanatory.

## 5.3 Desenvolvedor

| Label (pt-BR) | Control | Default | Status | Variable |
|---|---|---|---|---|
| Mostrar erros críticos | Toggle | Off | Ready | `ShowCriticalErrors` |

`DevWarUserFigure` and `DevWarUserSex` are also persisted but are **internal state**, not settings —
they back up the user's real figure during a dev war. They must **not** appear in the UI.

## 5.4 Dados

Actions rather than settings. These want buttons, and the destructive one wants a confirmation step.

| Label (pt-BR) | Control | Behaviour | Status | Command |
|---|---|---|---|---|
| Exportar configurações | Button | Writes the `.sol` file to a chosen location | Ready | `:solexp` |
| Importar configurações | Button | Reads a `.sol` file, then **force-closes the client** | Ready | `:solimp` |
| Restaurar padrões | Button (destructive) | Resets every setting to default | Ready | `:resetvars` |

Two hazards worth designing around:

- **Importar** force-exits the app on completion. The user must be warned *before* the file picker
  opens, not after.
- **Restaurar padrões** is irreversible and wipes everything, including saved looks and hotkeys.
  Needs a confirmation dialog.

---

# 6. Summary

| Category | Topics | Settings |
|---|---|---|
| 1 — Cliente | Aparência, Desempenho, Áudio | 13 |
| 2 — Chat | Aparência do chat, Balões, Silenciar e filtrar, Entrada e comandos | 18 |
| 3 — Quarto | Renderização e cores, Zoom e câmera, Mobis, Bloqueios, Sobreposições | 21 |
| 4 — Avatar e Social | Avatar, Amigos, Notificações e privacidade, Extras Bobba | 11 |
| 5 — Avançado | Atalhos, Ping, Desenvolvedor, Dados | 11 |
| **Total** | **19 topics** | **74** |

New controls required, in rough order of effort: toggle (exists), button (exists), segmented,
slider, stepper, text input, dropdown, colour picker, key capture, managed list.

The four managed lists (word filter, saved looks, hotkeys, and arguably the FX picker) are the
heavyweight items. If scope needs cutting for a first release, those are the natural candidates to
defer — they all have working chat commands today, so deferring them costs convenience, not
capability.

---

# 7. Deliberately excluded

Not everything configurable belongs in a settings window.

- **`DevWarUserFigure` / `DevWarUserSex`** — internal backup state, not user settings.
- **`SeasonalColorsActive`, `DevWarIsOpen`, `DevWarAdvicePending`, `LinkPortRequested`,
  `ObjectHighlighterIdsLimit`** — runtime flags with no user-facing meaning.
- **Server feature flags** (`discord.enabled`, `zoom.enabled`, `avatar.expression.67.enabled` and
  ~300 others) — pushed by the server, not user-editable. Some of them *gate* rows above, so a
  setting may need to hide entirely when its flag is off.
- **Discord settings** — already has its own server-backed panel; out of scope unless we want to
  absorb it.

---

# 8. Reference

| What | Where |
|---|---|
| All 54 persisted settings and their defaults | `cleanswf/scripts/com/sulake/habbo/window/LilithCustoms.as:2026-2082` |
| Persistence read/write | `LilithCustoms.as:2085` (`UpdateVariableValue`) |
| Existing toggle facade (7 keys) | `LilithCustoms.as:3915` (`GetBobbaToggle`) and `:3937` (`SetBobbaToggle`) |
| Existing settings panel | `cleanswf/scripts/com/sulake/habbo/window/utils/bobba/BobbaHelperView.as` |
| Window shell template | `.../bobba/BobbaHelperEditor.as` |
| Unwired settings button | `BobbaHelperView.as:203` |
| Settings layout tweaker | `tools/bobba-settings-tweaker.html` |
| Vanilla settings categories | `cleanswf/scripts/com/sulake/habbo/toolbar/extensions/SettingsExtension.as:35-47` |
| Command reference (base64) | `LilithCustoms.as:287` |

Storage is a single Flash SharedObject named `HabboAirPlus`. Saving **clears the entire store and
rewrites it**, so any new setting must be registered in the block at `LilithCustoms.as:2026` or it
will be silently lost on the next save.
