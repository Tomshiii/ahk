# <> Release 2.11.x - 

## > Functions
- Add `prem.accelScroll()`
- Add `prem.Excalibur.lockTracks()`
- Removed `convert2()` and `ytDownload()` and replaced with `ytdlp {` & `ffmpeg {`
    - All scripts that called these functions have been updated
    - Removed `trim {` from `trim.ahk` and moved to `ffmpeg {`
        - `trim.ahk` moved from `..\lib\Classes\` to `..\lib\GUIs`
- `getHTMLTitle()` will now sanitise ` - YouTube` from titles

## > Other Changes
- Fix `autosave.ahk` potentially throwing during backup