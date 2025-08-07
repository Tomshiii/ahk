# <> Release 2.16.x - 

## Functions
- ✅ Fixed `getHotkeys()` failing to return `Fxx` keys
- ✅ Fixed `switchTo.explorerHighlightFile()` failing to focus a directory if a window already existed, causing it to open a new instance
- ✏️ Added `getHotkeysArr()`
- 📋 `reset {` functions should now more reliably handle `HotkeylessAHK` causing the script to hang less often

⚠️ `keys {`

📍 `allWait()`
- 📋 Now uses `getHotkeysArr()` instead of heavy string manipulation
- 📋 Parameter `which` is now an `Integer` instead of a `String`

⚠️ `startup {`
- ✅ Fixed `adobeVerOverride()` showing the currently set adobe versions twice
- 📋 `trayMenu()` will now attempt once to open `HotkeylessAHK` if it is closed

⚠️ `ffmpeg {`
- ✅ Fixed `isVideo()` incorrectly labelling some video files as non videos
- 📋 Process completed alert now uses `Notify {`

`ytdlp {`
- ✅ Fixed `download()` setting `currentName` incorrectly if the user is using the default audio command
- 📋 Process completed alert now uses `Notify {`

⚠️ `ps {`
- ❌ Removed `Save()`
- 📋 `Type()` now uses UIA to set the correct filetype making it vastly more reliable

## Other Changes
- ✅ Fixed `mult-dl.ahk` throwing when attempting to highlight the output file
- 📋 This repo's version of `HotkeylessAHK` is now stored in `..\Backups\Adobe Backups\Premiere\HotkeylessAHK\HotkeylessAHK.ahk`