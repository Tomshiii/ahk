# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `startup.generate()` not always setting `MainScriptName`
- ✅ Fixed `rbuttonPrem {` not ending early if the user simply taps a button, but the script has to use `dismissWarning()`
- ✅ Fixed `premUIA_Values {` still attempting to set UIA values even if another window is obstructing its ability to do so

⚠️ `prem {`
- ✏️ Added `setScale()`
- ✏️ Added `rippleCut()`
- ✅ Fixed `save()` not actually getting a return value for the current sequence
- 📋 `__remoteFunc()` will now return boolean `true`/`false` instead of a string
- 📋 `zoomPreviewWindow()` now accepts parameter `zoomToFit` and internally handles versions of Premiere >=25.2 having a global hotkey to set the window to `fit`. (it ends logic early if the user's premiere version is set to >=25.2)
- `numpadGain()`
    - Will now inform the user if it times out
    - Can now be cancelled by pressing <kbd>Escape</kbd>