# <> Release 2.6.x - 
`class ptf {` *(point to file)*
- Replace `ImageSearch` `global variables` path variables
- Add as many directory locations as possible as class variables
- Add as many file directory locations as a map `files`

## > My Scripts
- `^AppsKey:: ;ahksearchHotkey;` will now attempt to check the tab the user opened to see if an error page opened instead.
- Added `#F12:: ;panicExitHotkey;` to run `reload_reset_exit("exit")`
- Added `SC03A & F5:: refreshWinHotkey` to refresh the current active window.

`#c:: ;centreHotkey;` 
- Will now ensure the `monitor` object is actually set before continuing to stop errors
- Fixed bug where if the window was overlapping multiple monitors, it would error and fail to center the window

## > Functions
- Fixed `activeScripts()` being unable to relaunched if closed with `x` windows button
- `reload_Reset()` changed to `reload_reset_exit()` and can now close all active ahk scripts
- `tomshiBasic()` can now pass in font size/weight settings
- `hotkeysGUI()` now uses objects, maps & Arrays to define it's values
- `updateChecker()` will now correctly stop itself checking for an update when the user has selected that as their setting

`refreshWin()`
- Can now determine the filepath of `notepad` & `explorer.exe` windows if the user passes `"A"` to both parameters of the function
- Now has fallback code if the window fails to close/reopen

## > Other Changes
- Removed a lot of lingering `location` variables from `Streamdeck AHK` scripts
- Removed reduntant version tracking of some scripts

`checklist.ahk`
- Changed `msgboxName()` to `change_msgButton()` to stop incorrect autocomplete in VSCode
- `About` & `Hours Worked` GUI now follow dark mode settings
- Removed duplicate dark mode functions from `menubar.ahk`