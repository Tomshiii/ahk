# <> Release 2.13.x - 

## > Functions
- `switchTo.adobeProject()` will now copy the project path to the user's clipboard if they instead activate the function twice in rapid succession

## Streamdeck AHK
- Fixed `audSelect.ahk` & `vidSelect` still failing under certain conditions
- Fixed `cmd.Result()` failing to provide a result under certain conditions
- Fixed `prem.screenshot()` throwing under certain conditions
- Fixed `prem.gain()` focusing the cancel button due to `Premiere` changing the <kbd>Tab</kbd> order
- `..\download\` scripts now pass `--recode-video mp4` instead of using `ytdlp().handleDownload()` to automatically reencode any files to `.mp4`
- Added `extractAll.ahk`
    - `extractAudio.ahk` renamed => `extractSingle.ahk`
    - Both moved to `..\Streamdeck AHK\extract audio\`
- Added `Slack {`
    - Added `Unread()`

## > Other Changes
- Fixed `autosave.ahk` not respecting `beep` setting
- Removed lingering `checklist wait` setting from `settingsGUI`