# <> Release 2.3.2.1

## > Functions
- Fixed missing backticks (\`) from `errorLog()`
- Fixed program filepaths in `switchTo.ahk`

## > Other Changes
- Put all `WinGet` in a `try {}/catch {}` to stop any errors when attempting to get information on/activate a no longer open process
- Minor changes to `RAlt & p` hotkey
- Removed `ImageSearches` from `^+w` hotkey
- Fixed incorrect variables in uses of `errorLog()` in `autosave.ahk`