# <> Release 2.13.x - 

## > Functions
- Fixed `prem.selectionTool()` failing to fall back to keyboard shortcuts if the image cannot be found
- Fixed `discord.surround()` always failing and forcing `ClipWait` to time out
- `WinGet.ExplorerPath()` now uses code by `lexikos` to correctly function with win11 explorer tabs

`ytdlp {`
- `download()`
    - Will now work with `facebook` & `reddit` links
    - Will now alert the user if the URL isn't a known to work link and will ask if they wish to attempt a download regardless

## > Streamdeck AHK
`download` scripts;
- All scripts now employ a filename size limit which can be set in `options.ini` (see below). This is to help avoid circumstances where a filename may become too large and corrupt itself upon download
- All scripts now pass `--windows-filenames`

Renamed;
- `SD_ptf {` => `SD_Opt {`
- `Streamdeck_ptf.ahk` => `Streamdeck_opt.ahk`
- `..\Support Files\Streamdeck AHK\dirs.ini` => `options.ini`

## > Other Changes
