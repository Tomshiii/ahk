# <> Release 2.8.2 -
- Broke apart `Windows.ahk` into individual function files
- `generateUpdate` no longer uses `FileAppend` to create the install `.exe` and instead copies `install.ahk` and renames it. This is functionally identical but easier to maintain

#### (#7) Attempt to fix issue #6 (couldn't reproduce the issue)
`Extract.ahk`
- Added more logic to check whether the user needs additional tools to unzip
- Fixed script still attempting to use `PowerShell` even if the script had prompted them to install `PowerShell 7`

## Functions
- Add `checkImg()` to check for a file and perform an `ImageSearch`
- Add `winget.FolderSize()` to return the size of a dir in `bytes`
    - `startup.adobeTemp()` now uses `winget.FolderSize()` to instantlly get the size of all cache directories instead of looping through them all
- `gameCheckGUI()` will now alert the user if the input window is already in the list
- Fix `fastWheel()` not focusing code window in `VSCode`
- `monitorWarp()` stores and returns coordmode
- `prem.gain()` will now properly timeout if gain window never appears
- All `switchTo` functions that use `WinWait` now timeout after `2s`

`settingsGUI()`
- Added a menubar
    - Moved `add game to 'gamecheck.ahk'` & `open settings.ini` into the menu bar
    - Added ability to open the wiki of this repo (both the local copy & web)

`discord.Unread()`
- Fix functon sometimes moving mouse to the incorrect position
- Will check (for `1.5s`) for the `Mark as Read` button

## > QMK
- `AE.ahk - l::` will now ensure the caret is active before attempting to send text

## > Streamdeck AHK
- `adjustment layer.ahk` when used while premiere is active will now set all options to standard & 60fps
- `vfx.ahk` & `video.ahk` will now download in `.mp4`

`ytDownload()`
- Will now check for any highlighted text before falling back to checking the clipboard
- Will attempt to open/activate the destination folder after download is complete

## > Other Changes
- Used `Format()` in a lot of longer strings that contain variables to make them more readable

`autosave.ahk`
- If no save is necessary, the next save attempt will be made in `1/2` the usual time.
    - eg. If autosave is set to save every `5min` and no save is necessary, the next attempt will happen in `2.5min`
- Fix sometimes failing to save
- Fix sometimes cutting on the timeline
- Fix variables not actually updating

`checklist.ahk`
- `openProj()` will now double check that either premiere/ae is open