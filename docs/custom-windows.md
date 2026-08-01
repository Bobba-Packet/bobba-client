# Adding a custom window

[← Back to README](../README.md)

Both the Bobba Helper and the Trax Machine use the same shape:

```
chat command → LilithCustoms.ParseChatInput
             → HabboWindowManagerComponent.displayXxx()
             → XxxEditor   builds a Habbo frame from XML (chrome, drag, close)
                 └── display_object_wrapper
                       └── XxxView : Sprite   your pixels, loaded from the pack
```

The Editor owns the Sulake window; the View is plain `Sprite` drawing. Build custom pixel UI in the View — only fall back to Sulake XML widgets when you need native Habbo controls.

## Frame and canvas

The frame XML is a `<layout>` with one `<frame params="33025" style="1">` containing a `<display_object_wrapper params="16">` canvas, plus `margin_*` variables. With the typical margins 6/30/6/6, the frame is `VIEW_W + 12` by `VIEW_H + 36`; keep the XML and the view constants in sync or the canvas clips.

After `buildFromXML`, cast to `IFrameController`, set the margins and `procedure`, `center()`, then `setParamFlag(257, false)` and `setParamFlag(32768, true)` so the window drags by its header instead of its content, and hand your Sprite to the canvas with `setDisplayObject`.

## Two things that are easy to miss

- **Block room clicks.** Filling the Sprite is not enough — register the frame rect with `roomEngine.setMouseEventsDisabledRect("my_key", rect)` and remove it on hide/dispose, updating on `WE_RELOCATED`, `WE_RESIZED` and `WME_UP`. Do not `stopPropagation` in the capture phase on the View; that kills every child click.
- **Pixel art and fonts.** `smoothing = false`, `pixelSnapping.ALWAYS`, integer scales and whole-pixel coordinates. Fonts are `"Ubuntu"` and `"Ubuntu bold"` with `embedFonts = true`, `antiAliasType = "advanced"`, `gridFitType = "pixel"` — select the bold face by name, never `TextFormat.bold`.

## Recipe

Copy an Editor/View pair, rename, strip the View to a background and one text field, add both to `merge.helpers` (see [Editing ActionScript](editing-actionscript.md)), add `displayXxx()` plus disposal on the window manager, hook the command in `LilithCustoms`, drop assets in `brand-pack/`, then inject and test.
