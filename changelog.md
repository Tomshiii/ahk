# <> Release 2.14.3 - QoL & Hotfix

## Functions
- Fixed `run at startup` checkbox in `settingsGUI()` throwing
- Fixed `ffmpeg().all_XtoY()` passing too many paramaters to `__determineFrameRate()`
- Added `startup.updatePackages()` to check for updates with the user's respective Package Manager
> [!Note]
> The code for this function (especially the portion that sends the command to actually update packages) is specifically designed for `Chocolatey`. While there are paramaters for the function to customise it for your package manager of choice, it may not function completey as intend. Feel free to open an issue/pr detailing as much as you can if you encounter any issues and rudimentary support for additional package managers may be considered (though not guaranteed)  
> Alternatively you can simply alter the code for your package manager of choice
- `premUIA_Values().__setNewVal()` now prompts the user to reload scripts

- `prem {`
- `numpadGain()` should now move clips on the timeline less often
- `previews()` (& `render and replace.ahk`) will now reattempt to send the hotkey `once` if the timeline was the originally focused panel

`rbuttonPrem().movePlayhead()`
- Now uses `WinEvent` to halt the function as soon as the main Premiere window is no longer active
- Now checks the originally focused panel using `UIA {` and uses that to determine if it needs to initially attempt to focus the timeline
> [!Note]
> Both of these changes should help in reducing the frequency of the function causing Premiere to cycle sequences (for example if the function was activated/active while the save dialog window appears, or if the user activated the function during an `autosave.ahk` save attempt)

## Other Changes
- Fixed `screenshot` streamdeck scripts failing to work if the timeline isn't the focused panel
- Added `swap solo.ahk`
- Separated `Premiere` `v24.3` ImageSearch images back into their own folder
    - It has come to my attention that at some point between `v22.3.1` the `track` images have changed. Little things like this can go unnoticed for long periods of time unfortunately
- `ptf.MainScriptName` is now tracked in `settings.ini` instead to remove some friction when installing new versions of the repo
    - This value will now automatically get set when using `startup.generate()` in a user's custom `Main Script`

`autosave.ahk`
- Now checks the originally focused panel using `UIA {` and uses that to later determine if it needs to attempt to refocus the timeline
> [!Note]
> This change should help in reducing the frequency of the function causing Premiere to cycle sequences if it attempts to refocus the timeline at the end of its save attempt