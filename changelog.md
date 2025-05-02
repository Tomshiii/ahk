# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `startup.generate()` not always setting `MainScriptName`
- ✅ Fixed `rbuttonPrem {` not ending early if the user simply taps a button, but the script has to use `dismissWarning()`
- ✅ Fixed `premUIA_Values {` still attempting to set UIA values even if another window is obstructing its ability to do so

`slack {`
- `button()`
    - ✅ Fixed function failing if attempting to be used in a reply thread
    - 📋 Now accepts parameter `replyInThread` to determine if `reply` will also enable the `Also send to...` checkbox when replying in a thread

⚠️ `prem {`
- ✏️ Added `setScale()`
- ✏️ Added `rippleCut()`
- ✅ Fixed `save()` not actually getting a return value for the current sequence
- 📋 `__remoteFunc()` will now return boolean `true`/`false` instead of a string
- 📋 `zoomPreviewWindow()` now accepts parameter `zoomToFit` and internally handles versions of Premiere >=25.2 having a global hotkey to set the window to `fit`. (it ends logic early if the user's premiere version is set to >=25.2)
- `numpadGain()`
    - Will now inform the user if it times out
    - Can now be cancelled by pressing <kbd>Escape</kbd>
- `dismissWarning()`
    - ✅ Fixed function randomly moving to the program monitor while attempting to `Ripple/Rolling Edit` using `Ctrl/Alt` in premiere v25.3
    - 📋 Now accepts parameters `waitWinClose` & `window`
        - `waitWinClose` defaults to `true` and will cause the function to wait `5s` to ensure the error message closes to hopefully stop instances where it can get stuck in a loop