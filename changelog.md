# <> Release 2.3.5 - First Run Experience
With [over 50 commits](https://github.com/Tomshiii/ahk/compare/v2.3.4...v2.3.5) it's been a big month for these scripts! so many quality of life improvements/fixes have come about in the last month as well as some fun and incredibly useful additions! I'm really excited to get this release out!

This release is centered around improving the experience for first time users of this collection of scripts. Scouring github for other AHK script collections I noticed something, trying to figure out what someones script collection *does* is incredibly difficult and time consuming, half because most don't bother to document anything and half because it's someone elses project and I just don't know where to begin so, while the main readme of this repo does a relatively decent job at explaining things, most users likely won't read it outside of the installation instructions and skimming it for a brief synopsis. So with this release comes `firstCheck()` as well as `#F1::` & `#h::` hotkeys.

- `firstCheck()` will prompt the user with an informational GUI on the first time running `My Scripts.ahk`, this GUI will give a brief rundown of the purpose of my scripts as well as informing the user of useful hotkeys to help them get started
- `#F1::` will bring up an informational GUI showing all active scripts (of this repo), as well as giving quick and easy access to enable/disable any of them at the check of a box
- `#h::` will bring up an informational GUI showing some useful hotkeys available to the user while running these scripts

## > `checklist.ahk`
This release also brings along a project I've had sitting in the background for quite sometime - [`checklist.ahk`](https://github.com/Tomshiii/ahk/blob/main/checklist.ahk) is a little script designed for me to keep track of what I have left to do on an editing project as well as keeping track of the amount of time I've put into a given project.

## > My Scripts
- Moved `#f` & `#c` so they can be used on any program
- Pressing `F1::` or `F2::` while `discord` is active will click on unread servers/channels respectively

`Ralt & p::`
- Can now find the project window even if it's on another display
- Will centre the `sfx` explorer window on the main monitor before attempting to drag it onto the project window to ensure it's not in the way

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
- `switchToFirefox()` changed so that if activated again once firefox is active it will cycle between firefox windows instead of tabs
- `switchToAE()` will attempt to open the AE file relating to my premiere project before falling back to just opening AE normally

`audioDrag()`
- Now has additional code when using the bleep sound effect to; trim, reduce the db and drag to track 1
- No longer attempts to empty the search field at the end of the function as it was rather unreliable and is an unnecessary step
- Removed remaining reference to vlc in a tooltip

`After Effects.ahk`
- Added `motionBlur()` to quickly navigate to the composition settings to increase the `Shutter Angle` to `360°` and activate motion blur on the top most track
- `aeScaleAndPos()` now increases search area on failure in an attempt to grab the requested value if the mouse is too far to the right the first time around

## > QMK Keyboard
- Added `x::` to open the project path when Premiere Pro or After Effects is open
    - `s::` (opening the checklist) will now automatically open the current projects checklist if Premiere or AE is open, else it will fallback to a dir search
- Added `v::` to activate/deactivate the margin button in Premiere
- Fixed `errorLog()`s containing `A_ThisFunc` instead of `A_ThisHotkey`

## > Other Changes
- Fixed a few remaining `Streamdeck AHK` scripts that still contained hard coded dir's
- Added `convert mp42mp3.ahk`
- Added `\Support Files\qmk keyboard images` to backup the cutouts I use for my secondary keyboard
- `readme.md` updated with clearer download instructions

`autosave.ahk`
- Will now properly reactivate an explorer window
- Will now check to make sure a save is required for either Premiere/After Effects or both before moving forward
- Fix small chance script will get stuck and unable to progress
- Will now search the entire right side of the screen for the stop button on the project monitor instead of relying on ClassNN values as they choose to break whenever they feel like it
- Will now properly rehighlight the timeline when completed

`right click premiere.ahk`
- Pressing `LButton` while holding down `RButton` will begin playback on the timeline once you've finished moving the playhead
- Pressing `XButton2` while holding down `RButton` will begin 2x playback once you've finished moving the playhead
    - `mousedrag()` was updated to allow for this change

`premiere_fullscreen_check.ahk`
- Default fire rate changed from `10s` to `5s`
- Now creates a tooltip when it attempts to fix your premiere window but is stopped due to the user interacting with a keyboard