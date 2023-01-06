# <> Release 2.9 - Huge Refactor
Welcome to the first release of 2023! 🎉🎉  
This release is a rather large one, containing a bunch of rather breaking changes to already existing parts of my code. If you use any of my functions for your own tinkering, paying close attention to this changelog is recommended if you're interested in updating.

- Added `class timer {` to quickly and easily build more complex timer functionality

## > errorLog()
- No longer takes a `backupVar` for every parameter instead **_requiring_** an `Error Object` to be passed into the function
- Can now have an optional message that will appear on a new, tabbed line
- Can now automatically generate a `tool.Cust()` tooltip from the passed in error object
    - This parameter can have an object passed into it to generate a custom tooltip, or it will simply generate a default `tool.Cust()` tooltip that lasts `1.5s`
- Can now automatically `throw` with the passed in Error Object

## > settingsGUI()
- Editor settings can now be accessed as separate GUIs through the menubar
    - Removed the two edit controls to change prem/ae year from the main GUI
    - These GUI windows offer the opportunity in the future to potentially support more than just one version of AE/Prem

## > obj {
Added a new class `obj {` to maintain a collection of wrapper functions designed to take normal ahk functions and return their VarRefs as objects instead

- Added `obj.WinPos()`
- Added `obj.ctrlPos()`
- Added `obj.imgSrch()` using `checkImg()`
- Moved `SplitPathObj()` and renamed to `obj.SplitPath()`
    - Fixed all instances of scripts that use this function not having the proper `#Include`
- Moved `getMousePos()` and renamed to `obj.MousePos()`

## > clip {
Added a new class `clip {` to maintain a collection of functions designed to manipulate the clipboard.  
This class helps cut large chunks of repeated code when dealing with the clipboard and waiting for data to be copied.

## > coord {
- Added `coord.Client()` to set the pixel mode to `client`
- Expanded functionality of all functions to accept a parameter to adjust what they want to target

## > Functions
- Added `delaySI()` to send a string of `SendInput` commands spaced out with a custom delay
- Added `allKeyUp()` to attempt to unstick as many keys as possible by looping through `ScanCodes` & `Virtual Key Codes`
- Added `discord.surround()` to surround highlighted text with the desired characters
    - Added a hotkey to make \` surround the highlighted text in \` in `Discord`
- Fixed `block.On()` & `block.Off()` failing to do anything
- Fixed `prem.zoom()` erroring out if client hasn't been defined yet
- Removed `prem.num()` - it's old code that was superceeded by `prem.zoom()`
- `checkImg()` changed to support all normal ImageSearch `ImageFile options`
- `settingsGUI()` menu dropdown now follows darkmode setting
- `getHTMLTitle()` will now replace some html strings with their respective characters
- `prem.movepreview()` now uses the program window coordinates to get an initial position for the mouse
- `startup.monitorAlert()` can now be muted for the current day
- If `switchTo.AE()` encounters multiple `.aep` files in the project directory, it will now offer the user the ability to select which project to open instead of opening the first one it finds

`winget.AEName()/winget.PremName()`
- `AEName()` Updated to have complete feature parity with `winget.PremName()`
- Can now return objects containing all the variables instead of only requiring VarRefs
    - All `VarRefs` are now optional to help accommodate this
- `saveCheck` variable now returns a `boolean value` instead of a `string`
- If the desired window can't be found, the variables will now return `unset` instead of as empty strings

`ytDownload()`
- Now allows the user to pass an object to define if they want the function to convert the downloaded filetype to another filetype
- Can now properly handle `yt shorts` links
- Adjusted passed `args` of `vfx.ahk` & `video.ahk`

## > checklist.ahk
- Entire script has been refactored to make use of `class timer {`
    - `checklistTimer {`, `checklistLog {` & `checklistReminder {` have been created to extend off the base class
- `H:` float will now **always** show `3dp` even if the current hour value is a whole integer.
    > old: `H: 1.0 M: 0 S: 0` => new: `H: 1.000 M: 0 S: 0`
- Using `-sub`/`+add` is now instant and no longer requires 1s to process
- Added functions `checkTooltips()` & `checkDark()` to return settings relating to both instead of cluttering the main script with code

## > autosave.ahk
- Fix erroring out if Premiere itself autosaves automatically before `autosave.ahk` can
- Will no longer block mouse movements during a save attempt, will simply block any keyboard/mouse inputs

## > Other Changes
- `tomshiBasic()` now creates a hidden button to force focus to it instead of the first user defined ctrl
- `adobe fullscreen check.ahk` now uses `timer {`
- QMK `open dir of current project` now uses `winget.AEName()/winget.PremName()`
- `startup.updateAHK()` will no longer run the download directory if `Run installer after download?` is selected
- Restored the original `fastWheel()` function from `Release v2.7.0.1`
    - Moved Premiere `F14::` hotkeys to the bottom of `My Scripts.ahk` as they were the cause of my issues