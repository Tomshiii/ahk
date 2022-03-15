# <> Release 2.3.2.1

## > My Scripts
- On first startup will now delete `Error Logs` older than `30 Days`

## > Functions
- Fixed missing backticks (\`) from `errorLog()`
    - Streamlined function to remove repeat code
- Fixed program filepaths in `switchTo.ahk`
- `preset()` adjustments to avoid opening properties window
    - General improvements to make more reliable
    - Now waits for activation hotkey to be released before proceeding to avoid spam activations

## > autosave
- Fixed incorrect variables in uses of `errorLog()` in `autosave.ahk`
- Will now check during the save for After Effects & save it if it is open

## > Other Changes
- Put all `WinGet` in a `try {}/catch {}` to stop any errors when attempting to get information on/activate a no longer open process
- Minor changes to `RAlt & p` hotkey
- Removed `ImageSearches` from `^+w` hotkey
- Removed unnecessary references to a `SetWorkingDir` in some `Streamdeck AHK` scripts