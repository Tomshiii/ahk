# <> Release 2.10.1 - Stability Update
- Combined `getcmd()` & `runcmd()` into `class cmd {`
- Combined `allKeyUp()`, `allKeyWait()` & `checkKey()` into `class keys {`

## > Functions
- Add `Mip {` to automatically create a `Map()` with `CaseSense`set to false
- Fix `winGet.AEName()` failing to get winTitle when After Effects is in the background
- `checkImg()`/`obj.imgSrch()` now have a parameter to determine whether tooltips will fire when running into errors

`Prem()`

- `zoom()`
    - Client info is now stored in a nested class `ClientInfo {`
    - No longer requires hard coded logic paths for each new zoom toggle added
- `audioDrag("bleep")` can now be cancelled by pressing <kbd>Esc</kbd>

## > Other Changes
- Fix `Settings.ahk` failing to properly set `Adjust` values if set to `1/0`
- Fix some settings not being properly set within `settingsGUI()`
- `tiktok project.ahk` now prompts the user with a GUI to determine what resolution they wish the project to be changed to
    - Will now <kbd>Tab</kbd> through the `Sequence Settings` menu instead of trying to use `ImageSearch`

`checklist.ahk`
- Fix throwing when title can't be found
- Fix bug causing `VSCode` to get closed if open when checklist attempts to open
- Cut repeat code in main script file