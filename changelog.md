# <> Release 2.3.5 - First Run Experience
This release is focused around improving the experience of first time users of my collection of scripts. While the main readme of my repo does a relatively decent job at explaining things, most users likely won't read it outside of the installation instructions. So with this release comes `firstCheck()` and the `#F1::` hotkey.

- `firstCheck()` will prompt the user with an informational GUI on the first time running `My Scripts.ahk`, this GUI will give a brief rundown of the purpose of my scripts as well as informing the user of the new `#F1::` hotkey to get them started
- `#F1::` will bring up an informational GUI showing all active scripts, as well as giving quick and easy access to enable/disable any of them at the check of a box

## > My Scripts
`updateChecker()`
- Fixed tooltips in the scenario that the user has selected `don't prompt again`
- Removed code relating to `beta` releases. Outdated and no signs of use
- Shows a tooltip when run showing the current script version as well as the current release version on github
- `RAlt & p::` can now find the project window even if it's on another display

`adobeTemp()`
- Now waits for all tooltips to be expired before beginning
- Will wait for `firstCheck()` to be finished before beginning
- Now tracks the `A_YDay` in `A_Temp \tomshi\adobe\` and will only run once a day


## > Other Changes
- Small changes to `musicGUI()`

`right click premiere.ahk`
- Pressing `LButton` while holding down `RButton` will begin playback on the timeline once you've finished moving the playhead
- Pressing `XButton2` while holding down `RButton` will begin sped up playback once you've finished moving the playhead
    - mousedrag() was updated to allow for this change

`premiere_fullscreen_check.ahk`
- Default fire rate changed from `10s` to `5s`
- Now creates a tooltip when it attempts to fix your premiere window but is stopped due to the user interacting with a keyboard