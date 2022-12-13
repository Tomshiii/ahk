# <> Release 2.8.x -
- Broke apart `Windows.ahk` into individual function files

## Functions
- Fix `fastWheel()` not focusing code window in `VSCode`
- `monitorWarp()` stores and returns coordmode
- `prem.gain()` will now properly timeout if gain window never appears
- All `switchTo` functions that use `WinWait` now timeout after `2s`

## > QMK
- `AE.ahk - l::` will now ensure the caret is active before attempting to send text

## > Streamdeck AHK
- `adjustment layer.ahk` when used while premiere is active will now set all options to standard & 60fps
- `vfx.ahk` & `video.ahk` will now download in `.mp4`

`ytDownload()`
- Will now check for any highlighted text before falling back to checking the clipboard
- Will attempt to open/activate the destination folder after download is complete

## > Other Changes

`autosave.ahk`
- If no save is necessary, the next save attempt will be made in `1/2` the usual time.
    - eg. If autosave is set to save every `5min` and no save is necessary, the next attempt will happen in `2.5min`
- Fix sometimes failing to save
- Fix sometimes cutting on the timeline
- Fix variables not actually updating

`checklist.ahk`
- `openProj()` will now double check that either premiere/ae is open