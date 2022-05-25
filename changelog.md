# <> Release 2.3.5 - First Run Experience 

## > My Scripts
- Added `firstCheck()` which will prompt the user with an informational GUI on the first time running the script. This GUI will give a brief rundown of the purpose of my scripts as well as informing the user of the new `#F1` hotkey
- Added `#F1` which brings up an informational GUI showing all active scripts, as well as giving quick and easy access to enabling/disabling any of them at the check of a box

`updateChecker()`
- Fixed tooltips in the scenario that the user has selected `don't prompt again`
- Removed code relating to `beta` releases. Outdated and no signs of use
- Shows a tooltip when run showing the current script version as well as the current release version on github

`adobeTemp()`
- Now waits for all tooltips to be expired before beginning
- Will wait for `firstCheck()` to be finished before beginning


## > Other Changes
- Small changes to `musicGUI()`
- Pressing `Lbutton` during the use of `right click premiere.ahk` will now begin playback on the timeline once you've finished moving the playhead

`premiere_fullscreen_check.ahk`
- Default fire rate changed from `10s` to `5s`
- Now creates a tooltip when it attempts to fix your premiere window but is stopped due to the user interacting with a keyboard