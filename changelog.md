# <> Release 2.14.3 - QoL & Hotfix

## Functions
- Fixed `run at startup` checkbox in `settingsGUI()` throwing
- Fixed `ffmpeg().all_XtoY()` passing too many paramaters to `__determineFrameRate()`
- Added `startup.updatePackages()` to check for updates with the user's respective Package Manager
> [!Note]
> The code for this function (especially the portion that sends the command to actually update packages) is specifically designed for `Chocolatey`. While there are paramaters for the function to customise it for your package manager of choice, it may not function completey as intend. Feel free to open an issue/pr detailing as much as you can if you encounter any issues and rudimentary support for additional package managers may be considered (though not guaranteed)  
> Alternatively you can simply alter the code for your package manager of choice
- `premUIA_Values().__setNewVal()` now prompts the user to reload scripts

`prem {`
- `numpadGain()` should now move clips on the timeline less often
- `previews()` (& `render and replace.ahk`) will now reattempt to send the hotkey `once` if the timeline was the originally focused panel
- `gain()`, `mousedrag()` & `screenshot()` now all use `UIA {` when they need to focus the timeline
- `__uiaCtrlPos()` now accepts parameter `getActive` to determine whether you wish for the function to retrieve the active panel or not

`rbuttonPrem().movePlayhead()`
- Now uses `WinEvent` to halt the function as soon as the main Premiere window is no longer active
- Now focuses the timeline using `UIA {`
- Now checks that the initially active sequence is still the active sequence when the function is finished
> [!Note]
> All of these changes should help in reducing the frequency of the function causing Premiere to cycle sequences (for example if the function was activated/active while the save dialog window appears, or if the user activated the function during an `autosave.ahk` save attempt)

## PremiereRemote
- Added `getActiveSequence()` & `focusSequence()`

## Other Changes
- Fixed `screenshot` streamdeck scripts failing to work if the timeline isn't the focused panel
- Fixed some `Not Editor.ahk` scripts not firing under certain conditions
- Added `swap solo.ahk`
- Separated `Premiere` `v24.3` ImageSearch images back into their own folder
    - It has come to my attention that at some point between `v22.3.1` the `track` images have changed. Little things like this can go unnoticed for long periods of time unfortunately
- `ptf.MainScriptName` is now tracked in `settings.ini` instead to remove some friction when installing new versions of the repo
    - This value will now automatically get set when using `startup.generate()` in a user's custom `Main Script`
- Installation process will now replace previous `PremiereRemote` function files with updated versions if the user has `PremiereRemote` already installed
    - It will also backup the previous files in `A_AppData "\Adobe\CEP\extensions\PremiereRemote\host\src\backup\"`

`autosave.ahk`
- Now checks the originally focused panel using `UIA {` and uses that to later determine if it needs to attempt to refocus the timeline
- Now attempts to use `UIA {` to focus the timeline before falling back to previous methods
> [!Note]
> These changes should help in reducing the frequency of the function causing Premiere to cycle sequences if it attempts to refocus the timeline at the end of its save attempt