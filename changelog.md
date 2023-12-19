# <> Release 2.13.4 - Bugfix
There are still a few notable things I wanted to add/change before pushing another release but I feel the amount of things fixed has begun to get too high to continue delaying it. Being busy with work has just continued to make it difficult to work on any of the larger issues/projects.

## > Functions
- Fixed `cmd.Result()` failing to provide a result under certain conditions
- Fixed `reencodeGUI()` not focusing opened destination window correctly if it is already open
- Added `Slack {`
    - Added `unread()`
    - Added `button()`
- `switchTo.adobeProject()` will now copy the project path to the user's clipboard if they instead activate the function twice in rapid succession
- `refreshWin()` can now define whether the program is run elevated
- `rbuttonPrem().movePlayhead()` will now first check to ensure the main `Premiere` window is the active window before anything else. This should stop the function retrieving incorrect timeline coordinates if another window is currently stealing focus

`ffmpeg {`
- `all_HCrop()` => `all_Crop()`
    - Now has added option to define whether to crop horizontally or vertically
- `extractAudio()` will now place extracted audio streams in dir named after the file

`Prem {`
- Fixed `screenshot()` throwing under certain conditions
- Fixed `gain()` focusing the cancel button due to `Premiere` changing the <kbd>Tab</kbd> order
- Fixed `prem.wheelEditPoint()` having difficulties trying to select previous/next keyframes

## Streamdeck AHK
- Fixed `audSelect.ahk` & `vidSelect.ahk` still failing under certain conditions
- Added `extractAll.ahk`
    - `extractAudio.ahk` renamed => `extractSingle.ahk`
    - Both moved to `..\Streamdeck AHK\extract audio\`
- Added `vCrop` scripts to split clips vertically
    - `hCropGUI` => `cropGUI`
- Added `Change.ahk` screenshot script to set a new starting value
- `..\download\` scripts now pass `--recode-video mp4` instead of using `ytdlp().handleDownload()` to automatically reencode any files to `.mp4`

## > Other Changes
- Fixed `autosave.ahk` not respecting `beep` setting
- Fixed `CreateSymLink.ahk` failing to operate on the correct path
- Fixed `generateAdobeSym.ahk` requiring a dependacy. This script is expected to run before symlinks and as such should have none
- Removed lingering `checklist wait` setting from `settingsGUI`