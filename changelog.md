# <> Release 2.12 - New autosave.ahk
- `autosave.ahk` has been rewritten from the ground up to follow cleaner coding patterns allowing for easier expandability, easier debugging and allowing the script to do what it was originally designed to do while not encountering issue after issue as more and more responsibilities got attached to the one script.  
The purpose of this update is to smooth out the experience of using the script and allow it to do what it was always supposed to do; do it's thing in the background without interupting the user with countless unrecoverable errors.
> This currently means that `autosave.ahk` will lose the ability to automatically open `checklist.ahk` (as it shouldn't have ever been its responsibility anyway) and will no longer offer a countdown until the next automatic save. The removal of these features has been done after careful consideration to ensure that it doesn't end up in the same pit as before and remains clean and easily maintainable.
>> The settings for these features have currently been disabled within `settingsGUI()` while I decide whether I wish to bring them back in some capacity.

## > UIA Lib
This update adds the `UIA` lib from [Descolada](https://www.github.com/Descolada/UIA-v2). This library will allow the user to more efficiently interact with panels in `Premiere Pro`. The addition of this library requires some manual tinkering from the user to get going however and means a few Premiere functions are no longer plug and play.Checkout the [wiki page](https://github.com/Tomshiii/ahk/wiki/UIA) for more details on how the library is utilised within this repo, as well as how to adjust the settings for your own setup.

## > Adobe Transition
I am slowly transitioning my `Premiere Pro/After Effects` workflow over to `v23.5` and beyond.
> ⚠️ Code added from this release forward is no longer guaranteed to work on versions `v22.3.1(prem)/v22.6(ae)` as testing will now be conducted on newer releases of the program(s). ⚠️
>> *There shouldn't be much in the way of inconsistencies for the foreseeable future (as almost everything so far has worked in both versions fine) but this is the **offical cutoff point.***

## > Functions
- Fixed `gamCheckGUI {` failing to produce a `Msgbox` to alert the user a game has already been added to the list when the GUI is called from the tray menu.
- Fixed `startup.generate()` incorrectly generating new settings entries
- Added entry `MainScriptName` to `ptf {` so `My Scripts.ahk` isn't hardcoded where it doesn't need to be


`switchTo {`
- Fixed `__Win` throwing if target doesn't exist
- Add `adobeProject()` to open the current project in windows explorer.
    - Code taken from `Always.ahk` and replaced with this function
    - Fixed bug in original code that was causing the explorer window to not get focused once opened
- `Explorer()` now includes `"ahk_class OperationStatusWindow"` (ie. transfer graph)

`WinGet {`
- `title()` now has parameter `exitOut` to determine whether the user wishes for the active thread to exit if the function cannot determine the title. Defaults to `true`
- `id()` now returns the `id` on success instead of boolean `true`
- `PremName()/AEName()`
    - Now returns `-1` on failure instead of `unset`
    - Now attempts to determine the `year` value of the open window from the title itself before falling back to `ptf.AEYearVer/ptf.PremYearVer`

`Premiere_RightClick {`
- Fix script stalling if the user attempts to right click anywhere other than the timeline while its coordinates haven't been set
- Add additional colour to fix script failing to work on a target track within `in/out` points
- `checkStuck()` taken out and separated into its own function file

`prem {`
- Fixed `gain()` getting stuck if used multiple times in a row
    - Will also now double check to ensure audio is selected before attempting to open the gain window
- Fixed `getTimeline()` stalling when it encounters an issue
- Added `numpadGain()` which allows `gain()` to quickly be called by pressing <kbd>NumpadSub/NumpadAdd</kbd> followed by any of the <kbd>Numpad</kbd> buttons
- Added `__respondMessage` & `__parseMessageResponse` to allow for scripts to easily share information relating to premiere between one another. (ie. sharing timeline coordinates between scripts)
- `__checkTimelineFocus()` is now static
- `__checkTimeline()` & `getTimeline()` now accept a parameter to determine whether to produce tooltips
- `zoom()`
    - Fixed function cycling through timeline sequences if multiple are open
    - Preset zooms can now accept an array length of `5` to include the `Anchor Point` coordinates
    - All tooltips now appear at the bottom of the `Program Monitor` and no longer follow the mouse

## > Other Changes
- Fix `Alt_menu_acceleration_DISABLER.ahk` no longer working as expected in `AHK v2.0.4`
- Added `render and replace.ahk`
- Added `sendtoAE.ahk`
- Added `;vscodeTodoHotkey;`
- `adobe fullscreen check.ahk` will now work on any version of `Premiere Pro`/`After Effects` and no longer requires the correct year to be set within `settingsGUI()`
- `Multi-Instance Close.ahk` will now ignore `Move project.ahk`
- `checklist.ahk` will now create a `Hotkey` <kbd>Shift & Media_Play_Pause</kbd> to start/stop the timer
- Refactored the following timer scripts;
    - `adobe fullscreen check.ahk`
    - `autodismiss error.ahk`
    - `premKeyCheck.ahk`

`Logs`
- Added the class `log {` to allow for easier logging without the need for an `Error Object`
- `errorLog()` refactored into a `class` (that extends off `log {`) for cleaner code and easier expandability

> These changes do not break prior functionality of `errorLog()` and the only change necessary from a user perspective is adjusting the `#Include` location if used in any custom scripts.