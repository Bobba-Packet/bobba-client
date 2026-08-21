# Features

[← Back to README](../README.md)

Everything HabboAirPlus does (its full `:command` set, hotkeys, saved looks, room tweaks) plus the following.

## Branding

Login background, SSO token screen (logo + soft shadow), loading screen, and photo splash frame are re-skinned as *Bobba Client*. Images are loaded from disk at runtime instead of being baked into the SWF, so you can restyle the client by swapping PNGs in `brand-pack/` — no re-inject needed for pure asset changes. See [Assets](assets.md).

## Bobba Helper (`:bobba`)

A pixel-art window with the client's own toggles, persisted in the AirPlus `SharedObject`:

| Toggle | Effect |
|---|---|
| Anti AFK | Keeps the avatar from going idle (`:afk`) |
| Auto drop | Drops a hand item as soon as it is received (`:autodrop`) |
| Manter direção / Keep direction | After receiving a hand item, restores your previous facing (`:keepdir`) |
| Bloquear giro / Block turn | Blocks avatar turning (`:turnblock`) |
| Mover item de parede / Move wall item | Enables the wall-item mover described below |
| Chat em grupo · Sussurro em grupo · Desativar 67 · Anti-flood | **Chat em grupo** opens `:groupchat`. **Sussurro em grupo** enables avatar-menu / `:group` room whisper (Bobba sidecar only). **Desativar 67** is wired. **Anti-flood** stacks identical room bubbles from the same user as `Hi (2x)` instead of repeating them. |

Labels come from `brand-pack/i18n/` — **pt-BR** on `hhbr`, **es** on `hhes`, **fr** on `hhfr`, **English** on every other hotel. See [Assets](assets.md#i18n).

It also links to Discord and opens the Trax Machine. Toggles read and write through `GetBobbaToggle` / `SetBobbaToggle` on `LilithCustoms`, so adding a row is a label key in the locale JSON plus a case in that switch.

The window itself is built with the pattern described in [Adding a custom window](custom-windows.md). A skull button on the bottom bar (next to the camera, `bobba_menu.png`) toggles the same window.

## Group whisper (`:group` / `:grupo`)

Per-room multi-recipient whisper over the Bobba sidecar (never hotel chat).

1. Enable **Sussurro em grupo** in `:bobba`
2. On another user's avatar menu, under Whisper, click **Sussurro em grupo** / **Group whisper** to toggle them into your list (button only appears for Habbos registered on Bobba)
3. A small panel lists current targets (remove from there too)
4. Chat with `:group message` or `:grupo message` — bubbles show as whisper-style on each avatar
5. Changing rooms clears the list

Requires recipients to be online on Bobba with a linked `(hotelId, nickname)` profile.

## Wall item mover

With *Mover item de parede* on, the furni infostand for wall items grows an arrow pad (`brand-pack/wallmover/`) that nudges posters and wall furni pixel by pixel via `MoveWallItemMessageComposer`.

## Trax Machine (`:traxmachine` / `:trax`)

Also reachable from Bobba Helper → Extra. An in-client song editor: browse sound collections from `catalog.json`, preview tracks, place them on a multi-layer timeline, and play back. All MP3s and images stream from an external pack on disk, never from the SWF.

## Avatar editor Clothes button

Opens a separate **Bobba Clothes** avatar editor (unlocked wardrobe, instance 3) with `bobba_clothes_hero.png` behind the nickname. Visibility is gated by **Ver visuais Bobba** in `:bobba` (`BobbaLooksEnabled`); when that toggle is off, DevWar is also disabled. Closing the editor disposes wardrobe data from RAM and keeps only the look the user saved. Disabling the toggle reverts the avatar to its original clothing. Other Bobba clients in the same room see the look over the sidecar; nothing is sent to the Habbo hotel.

## Bobba avatar FX (NPCkey / BobbaKey)

NPCkey (fx 9002) and BobbaKey (fx 9001) appear in the wardrobe **Effects** tab. Official Metakey (fx 212) is unchanged. Save applies the Bobba overlays locally; nothing is sent to the Habbo hotel. Other Bobba users in the same room see them over the sidecar.

## Local room assets

Sulake's gordon CDN 404s the room placeholder SWFs, so the client ships them in `local_include/`. See [Assets](assets.md).

## Logger

`Logger.as` writes runtime traces to `applicationStorageDirectory` (`%AppData%\packet.bobba.airbobba.debug\Local Store\bobba_debug.log` under the debug descriptor), which `update-and-debug.bat` prints when ADL exits.

## Launch parity

Parity with AirPlus is intentional: `Habbo.exe -server <hotelId> -ticket <ssoTicket>`. There is no custom login UI; the SSO ticket comes from the launcher or clipboard.
