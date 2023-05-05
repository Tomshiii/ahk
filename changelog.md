# <> Release 2.11.x - 
- `right click premiere.ahk` has been removed and replaced with `Premiere_RightClick.ahk`
    - Entire script refactored to be contained within a class to allow for easier handling of variables, easier bug tracking & easier expanding

## > Functions
- Add `prem.accelScroll()`
- Add `prem.Excalibur.lockTracks()`
- Removed `convert2()` and `ytDownload()` and replaced with `ytdlp {` & `ffmpeg {`
    - All scripts that called these functions have been updated
    - Removed `trim {` from `trim.ahk` and moved to `ffmpeg {`
        - `trim.ahk` moved from `..\lib\Classes\` to `..\lib\GUIs`
- Removed `reload_reset_exit()` and replaced with `reset {`
- Fix `prem.preset("loremipsum")`
- `getHTMLTitle()` will now sanitise ` - YouTube` from titles

## > Other Changes
- Fix `autosave.ahk` potentially throwing during backup
- `Settings.ahk` will now check the current `version` value for `alpha`/`beta` and ensure it's formatted correctly so any `VerCompare` work as expected