# <> Release 2.3.2.1 - Hotfix

## > Error Logs
- First startup of `My Scripts.ahk` will now delete `Error Logs` older than `30 Days`
- Fixed some missing backticks (\`) in the output
- Streamlined function to remove repeat code
- Fixed incorrect variables in uses of `errorLog()` in `autosave.ahk`

## > Functions
- Fixed program filepaths in `switchTo.ahk`
- `preset()` adjustments to avoid opening properties window
    - General improvements to make more reliable
    - Now waits for activation hotkey to be released before proceeding to avoid spam activations

## > Other Changes
- Put all `WinGet` in a `try {}/catch {}` to stop any errors when attempting to get information on/activate a no longer open process
- Put all instances of `ControlGetClassNN` into a `try {}/catch {}` to avoid potential crashes
- Minor changes to `RAlt & p` hotkey
- Removed `ImageSearches` from `^+w` hotkey
- `autosave.ahk` will now check during the save process if After Effects is open & save it if it is
- Removed unnecessary references to a `SetWorkingDir` in some `Streamdeck AHK` scripts