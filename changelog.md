# <> Release 2.8.x -

## Functions
- Added `getHTMLTitle.ahk` to return the title of a passed html object
- Fixed `getHTML.ahk` not including proper `#Includes`
- `fastWheel()` will now check for the state of `LButton` to allow for bulk highlighting

## Streamdeck AHK
- `New Premiere.ahk` now copies a template `.prproj` file instead of manually creating one

`ytDownload()`
- Fix bug relating to incorrect filepath variable
- Fix function activating premiere instead of explorer
- Will now automatically convert downloaded mkv to mp4 files using `convert2`
    - Changed args for `video.ahk` and `vfx.ahk`