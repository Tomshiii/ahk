# <> Release 2.10.x - 
- Combined `getcmd()` & `runcmd()` into `class cmd {`
- Combined `allKeyUp()`, `allKeyWait()` & `checkKey()` into `class keys {`

## > Functions
- Fix `winGet.AEName()` failing to get winTitle when After Effects is in the background

`Prem()`

- `zoom()`
    - Client info is now stored in a nested class `ClientInfo {`
    - No longer requires hard coded logic paths for each new zoom toggle added
- `audioDrag("bleep")` can now be cancelled by pressing <kbd>Esc</kbd>

## > Other Changes
- Fix `Settings.ahk` failing to properly set `Adjust` values if set to `1/0`
- Fix `checklist.ahk` throwing when title can't be found