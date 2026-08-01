# Editing ActionScript

[← Back to README](../README.md)

Edit files in `cleanswf/scripts/`, then declare them in `patches/manifest.json`:

- `stage[]` — existing scripts to reimport. Keep this list minimal.
- `merge.helpers[]` — new classes you own.
- `merge.host` — the existing script they get merged into (currently `HabboWindowManagerComponent.as`).
- `packName` — external asset folder name (`bobba`).

Then re-run the inject and debug loop from [Getting started](getting-started.md#run-it-edit--inject--debug).

## FFDec cannot add new ABC class names

A brand-new `.as` file will not become a new class in the SWF. That is why `merge-helpers-into-script.ps1` inlines the Bobba and Trax helpers into the host script as file-private classes before staging. Put new classes under `cleanswf/scripts/com/sulake/habbo/window/utils/<pack>/`, list them in `merge.helpers`, and make sure the host is also in `stage[]`.

## Never reimport these

No matter how small the change:

| Script | What breaks |
|---|---|
| `IHabboWindowManagerComponent.as` | Interface slots (`#1069 registerHintWindow`) |
| `EventDispatcherWrapper.as` / `Core.as` | `IEventDispatcher` (`#1034`) |

Add new public methods on the implementation class only, never on the interface. Avoid mass reimports for the same reason.

## Parser gotchas

The FFDec AS3 importer treats `/**` as a division operator, so a JSDoc block silently kills the import of that file (with `-onerror ignore` you only notice via delta 0). Use `//` comments in anything you stage.

## Chat commands

Commands live in `LilithCustoms.as`: add the string to `AllowedCommands`, handle it in `ParseChatInput`, and register a default in `UpdateVariablesValues` if it should persist. Persistence is `SharedObject.getLocal("HabboAirPlus", "/")`, shared with upstream AirPlus — `:commands` lists everything in-client, and `:resetvars` / `:solexp` / `:solimp` reset, export and import the store.
