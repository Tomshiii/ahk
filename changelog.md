# <> Release 2.8.x -

## > Functions
- Added `getLocalVer()` to grab the local version of a script
- Added `checkInternet()` to check if the user has a connection to the internet
- Added `getHTML()` to cut repeat code
- Added `startup.updateAHK()` to check if there is an ahk update and prompt the user to download
- `firstCheck()` & `HotkeyReplacer.ahk` better center their titles
- Setting *either* the `x` or `y` values in `tool.Cust()` (but not both) will now offset the tooltip by that value from the current cursor position
- `zoom()` now resets toggles from `10s` => `5s`
    - Can now manually reset toggles by pressing `F5`

`errorLog`
- Will now check for an internet connection before attempting to get latest release information to stop it causing an infinite loop
- Will now trim any `newlines` or `returns`

`Discord.ahk`
- Update `discord.Button()` images for new discord font
- Removed `discord.Location()` this function hasn't been used in a long time & wasn't even functional

## > My Scripts
- Added an `Author` section at the top of the script

## > Other Changes
- Releases will no longer include any `.psd` files (this is to help save on filesize)
- `autosave.ahk` checking for `checklist.ahk` being open can now be toggled in `settingsGUI()`
- Fix `Streaming.ahk` having an incorrect `#Include`
- All scripts that use the command line now send their commands directly using `RunWait()` instead of opening `A_ComSpec` and using `SendInput`
- Fix `convert2` scripts having incorrect `#Include`
    - Now uses `winget.ExplorerPath()` to grab the path of the current window without needing to highlight the url bar