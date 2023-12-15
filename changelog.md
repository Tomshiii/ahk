# <> Release 2.13.x - 

## > Functions
- Fixed `cmd.Result()` failing to provide a result under certain conditions
- Fixed `reencodeGUI()` not focusing opened destination window correctly if it is already open
- Added `Slack {`
    - Added `unread()`
    - Added `button()`
- `switchTo.adobeProject()` will now copy the project path to the user's clipboard if they instead activate the function twice in rapid succession

`Prem {`
- Fixed `screenshot()` throwing under certain conditions
- Fixed `gain()` focusing the cancel button due to `Premiere` changing the <kbd>Tab</kbd> order
- Fixed `prem.wheelEditPoint()` having difficulties trying to select previous/next keyframes

## Streamdeck AHK
- Fixed `audSelect.ahk` & `vidSelect.ahk` still failing under certain conditions
- Added `extractAll.ahk`
    - `extractAudio.ahk` renamed => `extractSingle.ahk`
    - Both moved to `..\Streamdeck AHK\extract audio\`
- `..\download\` scripts now pass `--recode-video mp4` instead of using `ytdlp().handleDownload()` to automatically reencode any files to `.mp4`

## > Other Changes
- Fixed `autosave.ahk` not respecting `beep` setting
- Fixed `CreateSymLink.ahk` failing to operate on the correct path
- Removed lingering `checklist wait` setting from `settingsGUI`