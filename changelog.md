# <> Release 2.16.x - 

## Functions
- ✅ Fixed `getHotkeys()` failing to return `Fxx` keys
- ✏️ Added `getHotkeysArr()`
- 📋 `reset {` functions should now more reliably handle `HotkeylessAHK` causing the script to hang less often
- 📋 `ytdlp {` process completed alert now uses `Notify {`

⚠️ `keys {`

📍 `allWait()`
- 📋 Now uses `getHotkeysArr()` instead of heavy string manipulation
- 📋 Parameter `which` is now an `Integer` instead of a string

⚠️ `startup {`
- ✅ Fixed `adobeVerOverride()` showing the currently set adobe versions twice
- 📋 `trayMenu()` will now attempt once to open `HotkeylessAHK` if it is closed

⚠️ `ffmpeg {`
- ✅ Fixed `isVideo()` incorrectly labelling some video files as non videos
- 📋 Process completed alert now uses `Notify {`

⚠️ `ps {`
- ❌ Removed `Save()`
- 📋 `Type()` now uses UIA to set the correct filetype making it vastly more reliable

## Other Changes
- ✅ Fixed `mult-dl.ahk` throwing when attempting to highlight the output file
- 📋 This repo's version of `HotkeylessAHK` is now stored in `..\Backups\Adobe Backups\Premiere\HotkeylessAHK\HotkeylessAHK.ahk`