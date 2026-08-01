# Troubleshooting

[← Back to README](../README.md)

| Symptom | Cause |
|---|---|
| SWF size delta 0 after inject | Nothing imported — usually a `/** */` comment or a parse error; check `tools/inject-log.txt` |
| New class missing, or `VerifyError` | Helper not listed in `merge.helpers`, or the merged host was overwritten during staging |
| Blank or stale UI | ADL is running an old SWF, or a re-export wiped your edits in `cleanswf/scripts/` |
| `#1069` / `#1034` at startup | An interface, `Core` or `EventDispatcherWrapper` was reimported — restore the baseline and re-inject |
| `COMPONENT_EVENT_ERROR` after login | Room placeholder SWFs missing from `local_include/` |
| Asset 404 | The file is not in `bobba/` next to the *running* SWF; re-run the deploy step |
| Trax Machine opens empty | `traxmachine-pack/catalog.json` not found |
| Blurry pixels | Fractional scale or `smoothing = true` |
| Invisible or wrong-weight text | Missing embedded font, or `bold = true` instead of the `"Ubuntu bold"` face |
| Clicks walk the avatar | Missing `setMouseEventsDisabledRect` |

Background for the inject and import failures is in [Editing ActionScript](editing-actionscript.md); for the missing-file cases, in [Assets](assets.md).
