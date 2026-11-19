# <> Release 2.21.x - 

## Functions
- ✅ Fixed `statusIcon {` rendering over context menus while `keepOnTop` is set `true`
- ✅ Fixed `rbuttonPrem().movePlayhead()` throwing an error if `armSequenceGuard` fires directly as a save attempt begins
- 📋 `premUIA_Values {` now tracks panel changes using `WinEvent` hooks instead of constant polling
- 📋 Increased `defaultDelay` for `prem.delayPlayback()` from `400` => `850`
    - Can now be adjusted in `settingsGUI()`
- 📋 `reloadAll.ahk` will now attempt to reload prem/ae `UXP` panels

## Other Changes
- ✅ Fixed usage of `armSequenceGuard` in `autosave.ahk` & `prem.save()` causing sequence guard to get locked enabled