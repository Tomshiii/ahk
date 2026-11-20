# <> Release 2.21.0.3 - Hotfix
This update is a non-critical hotfix for release `2.21.0`<sup>[[changelog]](<https://github.com/Tomshiii/ahk/releases/tag/v2.21.0>)</sup>. If you encounter issues with Premiere sequences being stuck locked to the active sequence, it is recommended you install this update.

## Functions
- ✏️ Added `ksa.prem.slowDownIncrement`
- ✅ Fixed `statusIcon {` rendering over context menus while `keepOnTop` is set `true`
- ✅ Fixed `rbuttonPrem().movePlayhead()` throwing an error if `armSequenceGuard` fires directly as a save attempt begins
- ✅ Fixed `discord.button()` sometimes not doing anything on first use
- ✅ Fixed `__checkAERemoteFunc()`/`__checkPremRemoteFunc()` not updating their internal registry on regeneration
- 📋 `premUIA_Values {` now tracks panel changes using `WinEvent` hooks instead of constant polling
- 📋 Increased `defaultDelay` for `prem.delayPlayback()` from `400` => `850`
    - Can now be adjusted in `settingsGUI()`
- 📋 `reloadAll.ahk` will now attempt to reload prem/ae `UXP` panels

## PremiereRemote
- ✏️ Added `custom/` `spreadSelectedClips`, `flattenSelectedClips`

## Other Changes
- ✅ Fixed usage of `armSequenceGuard` in `autosave.ahk` & `prem.save()` causing sequence guard to get locked enabled