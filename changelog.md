# <> Release 2.14.x - 

## > Functions
- Fixed `premUIA_Values(false).__setNewVal()` failing to override values under certain circumstances

`prem {`
- `Previews()` will now wait an extended period of time to better account for Premiere slow down in larger projects
- `__waitForTimeline()` will now only check once per second in an attempt to stop it getting stuck in an extended loop

`adobeVerOverride()`
- Will now only fire on a fresh start and **not** on a reload
- Will reload all active scripts if it changes a value

## > Other Changes
- Fix `extractAll.ahk` missing an `InStr` parameter
- Added [`MouseHook {`](https://discord.com/channels/115993023636176902/1207794506095923350/1207794506095923350) by [nperovic](https://github.com/nperovic/)
    - `Premiere_RightClick.ahk` now uses `MouseHook {` to determine when `LButton`/`XButton2` are pressed