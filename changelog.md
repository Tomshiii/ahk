# <> Release 2.3.5 - First Run Experience
This release is focused around improving the experience for first time users of this collection of scripts. While the main readme of the repo does a relatively decent job at explaining things, most users likely won't read it outside of the installation instructions. So with this release comes `firstCheck()` as well as `#F1::` & `#h::` hotkeys.

- `firstCheck()` will prompt the user with an informational GUI on the first time running `My Scripts.ahk`, this GUI will give a brief rundown of the purpose of my scripts as well as informing the user of useful hotkeys to help them get started
- `#F1::` will bring up an informational GUI showing all active scripts, as well as giving quick and easy access to enable/disable any of them at the check of a box
- `#h::` will bring up an informational GUI showing some useful hotkeys available to the user while running these scripts

## > `Checklist.ahk`
This release also brings along a project I've had sitting in the background for quite sometime - `Checklist.ahk` is a little script designed for me to keep track of what I have left to do on an editing project as well as keeping track of the amount of time I've put into a given project.

## > My Scripts
- `RAlt & p::` can now find the project window even if it's on another display
- Moved `#f` & `#c` so they can be used on any program

`updateChecker()`
- Script will no longer error if run while not connected to the internet
- Fixed tooltips in the scenario that the user has selected `don't prompt again`
- Removed code relating to `beta` releases. Outdated and no signs of use
- Shows a tooltip when run showing the current script version as well as the current release version on github

`adobeTemp()`
- Now waits for all tooltips to be expired before beginning
- Will wait for `firstCheck()` to be finished before beginning
- Now tracks the `A_YDay` in `A_Temp \tomshi\adobe\` and will only run once a day

## > Functions
- Small changes to `musicGUI()`

`After Effects.ahk`
- Added `motionBlur()` to quickly navigate to the composition settings and increase the `Shutter Angle` to `360°`

## > QMK Keyboard
- Added `x::` to open the project path when using Premiere Pro or After Effects
    - `s::` (opening the checklist) will now automatically grab the project path as well
- Added `v::` to activate/deactivate the margin button in Premiere

## > Other Changes
- Fixed a few remaining `Streamdeck AHK` scripts that still contained hard coded dir's
- Added `convert mp42mp3.ahk`
- Added `\qmk keyboard images` to backup the cutouts I use for my secondary keyboard

`autosave.ahk`
- Will now properly reactivate an explorer window
- Will now check to make sure a save is required for either Premiere/After Effects or both before moving forward

`right click premiere.ahk`
- Pressing `LButton` while holding down `RButton` will begin playback on the timeline once you've finished moving the playhead
- Pressing `XButton2` while holding down `RButton` will begin 2x playback once you've finished moving the playhead
    - `mousedrag()` was updated to allow for this change

`premiere_fullscreen_check.ahk`
- Default fire rate changed from `10s` to `5s`
- Now creates a tooltip when it attempts to fix your premiere window but is stopped due to the user interacting with a keyboard