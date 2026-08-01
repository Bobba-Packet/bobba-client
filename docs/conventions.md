# Conventions

[← Back to README](../README.md)

- Keep AirPlus launch parity: same executable arguments, same ticket model, same `SharedObject`.
- Prefer external packs over baking assets into the SWF, and prefer solving things outside the SWF over growing `LilithCustoms`.
- Keep the `stage[]` list minimal, and never reimport interfaces, `Core`, or event dispatcher wrappers.
- Keep hotel SSO tickets and any credentials out of git.
- Bobba Packet code and packaging are GPL-3.0 (`LICENSE`); upstream HabboAirPlus keeps its original licenses, so credit LilithRainbows and pin the baseline SWF version. Code freedom is not trademark freedom — using the *Bobba Packet* / *Bobba Client* names in a fork needs org alignment.
- Habbo pixel art is fine as a nostalgia accent, but do not present Sulake's logos as this project's identity. Brand palette: accent `#138A36`, foreground `#EAE6E5`, background `#12130F`.
