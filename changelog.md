# <> Release 2.13.x - 

## > Functions
- Added `prem.delayPlayback()` to delay playback after a ripple trim
- Fixed `generateAdobeShortcut()` throwing when called from `settingsGUI()`
- Fixed `WinMonitor()` throwing when unable to determine the position of the passed in window
- `ffmpeg.all_XtoY()` now accepts parameter `frameRate` to determine what framerate you want the remux to obide by. This can help stop scenarios like a `60fps` file getting remuxed to `60.0002fps` which in turn helps with performance issues within NLE's like Premiere
    > `all_XtoY()` will attempt to determine a file's framerate using `ffmpeg` but if it fails/the result isn't an integer, it will use the passed in value

## > Other Changes
- Fixed `audSelect.ahk` & `vidSelect.ahk` not functioning
- Added `..\Streamdeck AHK\screenshots\` scripts
- `hCrop CamSingle.ahk` will now append `_cropped` to the resulting filename