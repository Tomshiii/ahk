# <> Release 2.12.x -
> ⚠️ This release is a minor hotfix update to `v2.12` which saw massive breaking changes to the repo. If you haven't yet seen the changelog for `v2.12` please checkout those changes [**here**](https://github.com/Tomshiii/ahk/releases/tag/v2.12) ⚠️


## > Functions
- Added `switchTo.PhoneProgs()`
- Fixed `prem.Excalibur.lockTracks()` silently failing if the parameter passed into the function is all lowercase
- `clip.wait()` && `clip.copyWait()` now accept parameter `ttip` to allow for disabling of tooltips on failure. This can be helpful as producing them adds about `100ms` to the total round trip of the function
    - Fixed `discord.surround()` behaving slowly if the user isn't highlighting any text

`cmd {`
- Added `cmd.deleteMappedDrive()`
- `remapDrive()` now has parameter `persistent` to determine whether the user wishes for the desired mapping to remain after system events such as `shutdown`/`restart`


## > Other Changes
- Update discord `Delete` image
- Extended `alt_menu_acceleration_disabler.ahk` changes from last release to all programs listed in `ahk_group Editors`
- `trim.ahk` will now show the currently selected file

`remapDrive.ahk`
- Now has option to delete the currently selected drive letter
- Can now toggle whether the desired mapping is `persistent`

`Streamdeck AHK`

Added;
- `..\download\` `projVideo.ahk`
- `..\lock\` `audio.ahk` & `video.ahk`
- `..\run & activate\` `editing stuff.ahk`
- `frame hold.ahk`
- `make sequence.ahk`