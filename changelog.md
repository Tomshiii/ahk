# <> Release 2.12.x -

## > Functions
- Added `switchTo.PhoneProgs()`
- Fixed `prem.Excalibur.lockTracks()` silently failing if the parameter passed into the function is all lowercase

`cmd {`
- Added `cmd.deleteMappedDrive()`
- `remapDrive()` now has parameter `persistent` to determine whether the user wishes for the desired mapping to remain after system events such as `shutdown`/`restart`


## > Other Changes
- Update discord `Delete` image
- Extended `alt_menu_acceleration_disabler.ahk` changes from last release to all programs listed in `ahk_group Editors`

`remapDrive.ahk`
- Now has option to delete the currently selected drive letter
- Can now toggle whether the desired mapping is `persistent`

`Streamdeck AHK`

Added;
- `..\download\` `projVideo.ahk`
- `..\lock\` `audio.ahk` & `video.ahk`
- `..\run & activate\` `editing stuff.ahk`
- `frame hold.ahk`
