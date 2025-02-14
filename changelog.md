# <> Release 2.15.x - 
A bug in the third party lib [`WinEvent`](<https://github.com/Descolada/AHK-v2-libraries/issues/15>) was causing `prem.dissmissWarning()` to never fire when used in `Premiere_RightClick.ahk`. This issue has now been recitified and is once again working as expected.

## Functions
- Fixed `prem.dismissWarning()` utilising incorrect coords
- Fixed bug with `trimGUI {` calculating the duration between two timecodes causing empty files to be generated
    - Will now warn the user if incorrect timecodes have been given
- Added `Reload` option to the `Exit` menu in `settingsGUI()`

`Prem {`
- Added `disableDirectManip()`
- Removed `keyreset()` & `keyframe()`. A simpler method could be created using `PremiereRemote` but no current plans to develop said function
- Removed `zoom()`
- `valuehold()`
    - No longer requires individual screenshots for each control, greatly simplifying the function and making it less prone to breaking
    - No longer adjusts the `blend mode` and all reference to that ability has been removed
    - No longer adjusts `levels`. That functionality is better left to `numpadGain()`
    - First parameter `filepath` renamed => `control` is now <kbd>Case Sensitive</kbd>

`startup {`
- Added `gitBranchCheck()` to check for upstream changes to the git branch and offer the ability to `pull` upstream changes
    - Can be toggled in `settingsGUI()` and defaults to `false`
- `libUpdateCheck()` now checks for `Notify Creator.ahk` updates
- `generate()` will now attempt a reload if it has added any settings entries
- Functions that `reload` or `reset` all scripts will now track their reloads to ensure they can only reload once per day
    - They will also all now use `Notify` to alert the user that a reload is taking place to minimise confusion incase multiple need to happen in succession

## Streamdeck AHK
- Added `updateGitBranch.ahk`
- `backupProj.ahk` now alerts the user once it begins the backup process
- `[aud/vid][Part/Select].ahk` scripts now better manage the clipboard to allow the user to copy/paste before the actual download process begins
- Removed;
    - `blend` scripts. I never built them out and it may be possible to just use `PremiereRemote` instead but no current plans to investigate or develop said function
    - `swap solo.ahk` and associated `ImageSearch` images. This functionality is better utilised using `prem.toggleLayerButtons("solo")`
    - `push to audition.ahk`, `syncWorkAssets.ahk` & `tiktok voice.ahk`

## Other Changes
- Removed all now obsolete `ImageSearch` images relating to `blend` scripts & `prem.valuehold()`