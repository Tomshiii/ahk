# <> Release 2.15.x - 
A bug in the third party lib [`WinEvent`](<https://github.com/Descolada/AHK-v2-libraries/issues/15>) was causing `prem.dissmissWarning()` to never fire when used in `Premiere_RightClick.ahk`. This issue has now been recitified and is once again working as expected.

## Functions
- Fixed bug with `trimGUI {` calculating the duration between two timecodes causing empty files to be generated
    - Will now warn the user if incorrect timecodes have been given
- Added `Reload` option to the `Exit` menu in `settingsGUI()`  
![image](https://github.com/user-attachments/assets/2ee0243d-9ad4-45b4-8591-3207a5bd1b5a)  
- `rbuttonPrem {` will now return early in the event that `A_ThisHotkey` gets set as two keys

`Prem {`
- Added `disableDirectManip()`
- Fixed `dismissWarning()` utilising incorrect coords
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
- Functions that `reload` or `reset` all scripts will now track their reloads to ensure they can only reload once per day
    - They will also all now use `Notify` to alert the user that a reload is taking place to minimise confusion incase multiple need to happen in succession
- `generate()`
    - Fixed function improperly handling when a settings value is removed causing the setting to remain in the user's .ini file
    - Will now attempt a reload if it has added any settings entries

## Streamdeck AHK
- Added `updateGitBranch.ahk`
- `backupProj.ahk` now alerts the user once it begins the backup process
- `[aud/vid][Part/Select].ahk` scripts now better manage the clipboard to allow the user to copy/paste before the actual download process begins
- Removed;
    - `blend` scripts. I never built them out and it may be possible to just use `PremiereRemote` instead but no current plans to investigate or develop said function
    - `swap solo.ahk` and associated `ImageSearch` images. This functionality is better utilised using `prem.toggleLayerButtons("solo")`
    - `push to audition.ahk`, `syncWorkAssets.ahk` & `tiktok voice.ahk`

## Other Changes
- Removed all, now obsolete, `ImageSearch` images relating to `blend` scripts & `prem.valuehold()`
- Removed `Premiere Timeline GUI.ahk` and all references to it. The functionality of this script has long since been superseded by `Premiere_UIA.ahk`
- Added [`ObjRegisterActive.ahk`](<https://www.autohotkey.com/boards/viewtopic.php?f=6&t=6148&sid=79f2a3736ebcc2c9b88842b5a5145d27&start=40>)
    - `My Scripts.ahk` can now better share its instance of `prem {` with `QMK.ahk` scripts resulting in less UIA window focusing