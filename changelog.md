# <> Release 2.13.x - 

## > Functions
- Fixed `prem.selectionTool()` failing to fall back to keyboard shortcuts if the image cannot be found

## > Streamdeck AHK
`download` scripts;
- All scripts now employ a filename size limit which can be set in `options.ini`. This is to help avoid circumstances where a filename may become too large and corrupt itself upon download
- All scripts now pass `--windows-filenames`

Renamed;
- `SD_ptf {` => `SD_Opt {`
- `Streamdeck_ptf.ahk` => `Streamdeck_opt.ahk`
- `..\Support Files\Streamdeck AHK\dirs.ini` => `options.ini`

## > Other Changes
