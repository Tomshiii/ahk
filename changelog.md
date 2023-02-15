# <> Release 2.10.x - 
- Combined `getcmd()` & `runcmd()` into `class cmd {`
- Combined `allKeyUp()`, `allKeyWait()` & `checkKey()` into `class keys {`

## > Functions
`Prem()`

- `zoom()`
    - Client info is now stored in a nested class `ClientInfo {`
    - No longer requires hard coded logic paths for each new zoom toggle added
- `audioDrag("bleep")` can now be cancelled by pressing <kbd>Esc</kbd>

## > Other Changes
- Fix `checklist.ahk` throwing when title can't be found