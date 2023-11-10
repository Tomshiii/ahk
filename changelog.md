# <> Release 2.13.x - 

## > Functions
- Added `ffmpeg.extractAudio()` to extract all audio streams from a file
    - Added `extractAudio.ahk` streamdeck script
- Fixed `generateAdobeShortcut()` throwing when called from `settingsGUI()`
- Fixed `WinGet.WinMonitor()` throwing when unable to determine the position of the passed in window
- Fixed `cmd.result()` not producing a result if the return value was instead sent to the error stream
- `ffmpeg.all_XtoY()` now accepts parameter `frameRate` to determine what framerate you want the remux to obide by. This can help stop scenarios like a `60fps` file getting remuxed to `60.0002fps` which in turn helps with performance issues within NLE's like Premiere
    > `all_XtoY()` will attempt to determine a file's framerate using `ffmpeg` but if it fails/the result isn't an integer, it will use the passed in value

`prem {`
- Added `delayPlayback()` to delay playback after a ripple trim
    - Added `prem.rippleTrim()` to support this function
- Added `__uiaCtrlPos()` to cut repeat code when determining the position of controls using UIA
- Fixed `moveKeyframes()` containing old code causing it to break

`switchTo {`
- Added `Chrome()`
- `;ahksearchHotkey;` => `switchTo.ahkDocs()`
- Fixed firefox not being the focused window after being opened using `firefox()`

## > My Scripts
- All hotkey declarations have now been separated into individual scripts within `..\lib\My Scripts\` to make it easier to add new hotkey declarations to the correct place

## > Other Changes
- Fixed `audSelect.ahk` & `vidSelect.ahk` not functioning
- Added `..\Streamdeck AHK\screenshots\` scripts
- `hCrop CamSingle.ahk` will now append `_cropped` to the resulting filename