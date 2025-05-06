# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `startup.generate()` not always setting `MainScriptName`
- ✅ Fixed `rbuttonPrem {` not ending early if the user simply taps a button, but the script has to use `dismissWarning()`
- ✅ Fixed `premUIA_Values {` still attempting to set UIA values even if another window is obstructing its ability to do so
- ✏️ Added `switchTo.Path()` to change the desired windows explorer tab to a new `path`
- ✏️ Added `winget.getActiveExplorerTab()`
- 📋 `obj.MousePos()` now additionally returns the `control` the cursor is hovering over
- 📋 `startup.trayMen()` now has the ability to open the settings GUI for `Thio's Windows Explorer Script` mentioned down below

`slack {`
- `button()`
    - ✅ Fixed function failing if attempting to be used in a reply thread
    - 📋 Now accepts parameter `replyInThread` to determine if `reply` will also enable the `Also send to...` checkbox when replying in a thread

⚠️ `prem {`
- ✏️ Added `setScale()`
- ✏️ Added `rippleCut()`
- ✅ Fixed `save()` not actually getting a return value for the current sequence
- ✅ Fixed `dismissWarning()` firing when Premiere isn't the active window
- 📋 `__remoteFunc()` will now return boolean `true`/`false` instead of a string
- 📋 `zoomPreviewWindow()` now accepts parameter `zoomToFit` and internally handles versions of Premiere >=25.2 having a global hotkey to set the window to `fit`. (it ends logic early if the user's premiere version is set to >=25.2)
- `numpadGain()`
    - Will now inform the user if it times out
    - Can now be cancelled by pressing <kbd>Escape</kbd>
- `dismissWarning()`
    - ✅ Fixed function randomly moving to the program monitor while attempting to `Ripple/Rolling Edit` using `Ctrl/Alt` in premiere v25.3
    - 📋 Now accepts parameters `waitWinClose` & `window`
        - `waitWinClose` defaults to `true` and will cause the function to wait `5s` to ensure the error message closes to hopefully stop instances where it can get stuck in a loop

## Other Changes
- ✏️ Added a submodule for a [fork](https://github.com/Tomshiii/ThioJoe-AHK-Scripts) of [`ThioJoe's`](https://github.com/ThioJoe/) [AHK Scripts](https://github.com/ThioJoe/ThioJoe-AHK-Scripts/tree/main) repo
    - This brings [my own modified](https://github.com/Tomshiii/ahk/wiki/ExplorerDialogPathSelector.ahk) `MButton` functionality to windows explorer windows. Mainly focused around navigating a Premiere Project. *(this functionality expects you to use my project folder layout)*  
    <img src="https://github.com/user-attachments/assets/875278e5-f478-4a21-98a2-2d0615c948a1" width="275"/>
- 📋 Renamed `move 1sec.ahk` => `move playhead 1sec.ahk`
    - ✏️ Added `move 1sec.ahk`