# <> Release 2.3.2.2 - Hotfix

## > My Scripts
- Added `adobeTemp()` to delete Adobe cache files on first startup if they're larger than a user determined amount; `15GB` by default
- Fixed a few `ErrorLog` outputs
- Changed all `WheelLeft/WheelRight` to new `F{key}` assignments as LGHUB has recently broken those keys

## > Error Logs
- Now grabs and displays a whole bunch of system information on first firing of the current day 

## > autosave
- Now grabs the `ProcessName` instead of the `ClassName` to make reactivating the original window far more reliable
- Now stops itself from firing if the user interacted with the keyboard in the last `0.5s` and will attempt to retry `5s` later (both values are easily user adjustable towards the top of the script)
- Fixed some verbage to make differentiating between pausing/unpausing more obvious

## > Other Changes
- Minor changes to `SC03A & v` macro
- Capitalised the output of `toolFind()`
- `qss_firefox.ahk` scripts now check the active window during their loop to ensure the settings window gets activated