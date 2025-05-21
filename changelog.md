# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `premUIA_Values {` still attempting to set UIA values even if another window is obstructing its ability to do so
- ✏️ Added `switchTo.Path()` to change the desired windows explorer tab to a new `path`
- ✏️ Added `isURL()`
- 📋 `obj.MousePos()` now additionally returns the `control` the cursor is hovering over
- 📋 `settingsGUI()` will now only alert the user that settings are being saved if the user actually changed something

⚠️ `prem {`
- ✏️ Added `setScale()`
- ✏️ Added `rippleCut()`
- ✅ Fixed `save()` not actually getting a return value for the current sequence
- ✅ Fixed `toggleLayerButtons()` missing the `Mute`/`Solo` buttons at some track heights
- 📋 `__remoteFunc()` will now return boolean `true`/`false` instead of a string
- 📋 `zoomPreviewWindow()` now accepts parameter `zoomToFit` and internally handles versions of Premiere >=25.2 having a global hotkey to set the window to `fit`. (it ends logic early if the user's premiere version is set to >=25.2)
- 📋 `escFxMenu()` now closes the `Excalibur` window
- 📋 `anchorToPosition()` will no longer begin if the user isn't within a text field

📍 `layerSizeAdjust()`
- ✅ Fixed function causing zooming on the timeline if <kbd>LAlt</kbd> was held but the incorrect second activation key was pressed before holding the correct one
- ✅ Fixed function rewarping the cursor to the the edge of the timeline once finished
- 📋 Will now move the cursor to the top of the current layer so that shrinking its size will no longer cause the user to start adjusting the size of a layer below
- 📋 On function end will now move the cursor to the middle of the adjusted layer
- 📋 Now accepts parameter `capsLockDisable` to determine if <kbd>CapsLock</kbd> should be set back to `AlwaysOff` at the end of the function

📍 `wheelEditPoint()`
- 📋 Now uses `block_ext {` to block all keys except the activation keys
- 📋 Now accepts parameter `activationKeys` to pass through the user's activation keys so they aren't blocked

📍 `numpadGain()`
- ✅ Fixed function inexplicably failing if the `Effect Controls` window was active
- 📋 Will now inform the user if it times out
- 📋 Can now be cancelled by pressing <kbd>Escape</kbd>

📍 `dismissWarning()`
- ✅ Fixed function firing when Premiere isn't the active window
- ✅ Fixed function randomly moving to the program monitor while attempting to `Ripple/Rolling Edit` using `Ctrl/Alt` in premiere v25.3
- 📋 Now accepts parameters `waitWinClose` & `window`
    - `waitWinClose` defaults to `true` and will cause the function to wait `5s` to ensure the error message closes to hopefully stop instances where it can get stuck in a loop

⚠️ `rbuttonPrem {`
- ✅ Fixed `movePlayhead()` not ending early if the user simply taps a button, but the script has to use `dismissWarning()`
- ✅ Fixed script hard crashing under certain circumstances

⚠️ `startup {`
- ✅ Fixed `generate()` not always setting `MainScriptName`
- 📋 `trayMen()` now has the ability to open the settings GUI for `Thio's Windows Explorer Script` mentioned down below

⚠️ `winGet {`
- ✅ Fixed `ProjPath()` throwing when Premiere is open but a project hasn't been opened yet
- ✏️ Added `getActiveExplorerTab()`

⚠️ `discord {`
- ✅ Fixed `button()` throwing if it can't find the `reply` button
- ✅ Fixed `Unread("servers")` failing and throwing in the process

⚠️ `slack {`

📍 `button()`
- ✅ Fixed function failing if attempting to be used in a reply thread
- ✅ Fixed `button("reply")` failing to continue if the message already had a reply, or was a part of a thread
- 📋 Now accepts parameter `replyInThread` to determine if `reply` will also enable the `Also send to...` checkbox when replying in a thread

## Other Changes
- ✅ Fixed an issue causing `WinEvent` to throw across all scripts when reloaded
- ✏️ Added `toggleLinearColour.ahk`
- ✏️ Added a submodule for a [fork](https://github.com/Tomshiii/ThioJoe-AHK-Scripts) of [`ThioJoe's`](https://github.com/ThioJoe/) [AHK Scripts](https://github.com/ThioJoe/ThioJoe-AHK-Scripts/tree/main) repo
    - This brings [my own modified](https://github.com/Tomshiii/ahk/wiki/ExplorerDialogPathSelector.ahk) `MButton` functionality to windows explorer windows. Mainly focused around navigating a Premiere Project. *(this functionality expects you to use my project folder layout)*  
    <img src="https://github.com/user-attachments/assets/a5c2ae63-9b39-4284-b73e-3fa8bba5bf41" width="275"/>
- 📋 Renamed `move 1sec.ahk` => `move playhead 1sec.ahk`
    - ✏️ Added `move 1sec.ahk`
- 📋 `multi-dl` will now prefill URL if it determines one in the user's clipboard