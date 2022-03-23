# <> Release 2.3.2.2 - 

## > My Scripts
- Added `adobeTemp()` to delete Adobe cache files if they're larger than a determined amount

## > Functions
- Capitalised the output of `toolFind()`

## > autosave
- Now grabs the `ProcessName` instead of the `ClassName` to make reactivating the original window far more reliable
- Now stops itself from firing if the user interacting with the keyboard in the last `1.25s` and will retry `10s` later (both values are easily user adjustable towards the top of the script)
- Fixed some verbage to make differentiating between pausing/unpausing more obvious

## > Other Changes
- Minor changes to `SC03A & v` macro