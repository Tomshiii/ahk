# <> Release 2.8.x -

## Functions
- Fix `fastWheel()` not focusing code window in `VSCode`
- `monitorWarp()` stores and returns coordmode

## > QMK
- `AE.ahk - l::` will now ensure the caret is active before attempting to send text

## > Streamdeck AHK
- `adjustment layer.ahk` when used while premiere is active will now set all options to standard & 60fps
- `vfx.ahk` & `video.ahk` will now download in `.mp4`

`ytDownload()`
- Will now check for any highlighted text before falling back to checking the clipboard
- Will attempt to open/activate the destination folder after download is complete

## > Other Changes

`checklist.ahk`
- `openProj()` will now double check that either premiere/ae is open