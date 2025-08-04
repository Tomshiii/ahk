# <> Release 2.16.x - 

## Functions
- 📋 `reset {` functions should now more reliably handle `HotkeylessAHK` causing the script to hang less often

⚠️ `startup {`
- ✅ Fixed `adobeVerOverride()` showing the currently set adobe versions twice
- 📋 `trayMenu()` will now attempt once to open `HotkeylessAHK` if it is closed

⚠️ `ps {`
- ❌ Removed `Save()`
- 📋 `Type()` now uses UIA to set the correct filetype making it vastly more reliable

## Other Changes
- 📋 This repos version of `HotkeylessAHK` is now stored in `..\Backups\Adobe Backups\Premiere\HotkeylessAHK\HotkeylessAHK.ahk`