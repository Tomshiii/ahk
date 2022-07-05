# <> Release 2.4.x - 

Scripts now require `AutoHotkey v2.0-beta.5`

## > My Scritps
- `firstCheck()` & `adobeTemp()` now write their files to `A_MyDocuments` instead of `A_Temp` as the temp folder is periodly cleared by windows
- `updateChecker()` will now wait for previous tooltips to complete before moving forward in the event that the user has selected "do not prompt"
- Added `RAlt & p::` when firefox is active to pin the first two tabs
- `#c::` will now make a slightly larger window if the active window is a youtube window
- `RAlt & p:: (premiere)` now has the ability to *only* move the `Project` window to it's proper position if `Shift` is held
- Updated `unread.png` images for `F1::` & `F2::` discord hotkeys

## > Functions
- `switchToAE()` now able to find `.aep` file for the current working project regardless of name
- Updated `blur` images for `motionBlur()`
- Added `zoom()` to set and use custom zooms for individual Premiere Pro sessions

`openChecklist()`
- Fixed error on first startup of `Premiere`
- Replaced hard coded dir with `location` variable from `KSA.ahk`

`gain()`
- Fixed function waiting for window `"off"` to close instead of the proper `"Audio Gain"` window
- Removed code relating to `DroverLord - Window Class3` as the timeline isn't the only panel that can take on this Window Class, rendering the code detrimental on some occasions

`audioDrag()`
- Now shows a tooltip alerting the user it's waiting for an input before continuing
- Now has added functionality to not move the cut `bleep` sfx to track 1 if the user presses `c` while the function is waiting for the user to cut the sfx
- Moves the mouse over an extra time once the mouse has become the `Arrow`
- Will now attempt to drag the audio clip 3 times and will check for the default green colour before proceeding
- Can now move the `bleep` sfx to any audio channel between `A1-A9`

## > Other Changes
- Fixed comments in `Keyboard Shortcut Adjustments.ahk` that had been copy/pasted but never corrected
- `autodismiss error.ahk` will now ignore the `Clip Mismatch Warning` dialog that can appear in Premiere when you drag a clip to the timeline that doesn't match the sequence settings
- `checklist.ahk` will now log activating/deactivating any of the checklist items

`QMK Keyboard.ahk`
- Moved `switchToDisc()` from `My Scripts.ahk` to `QMK Keyboard.ahk`
    - Moved `switchToEdge()` to a different key
- The code to automatically open the checklist of the open project moved from `QMK.ahk` to `\Functions\Premiere.ahk` -> `openChecklist()`

`autosave.ahk`
- Will now timeout after 3s if it gets stuck while attempting to save
- Will now check to make sure the user has opened the `checklist.ahk` file for the current project. It will also attempt to open it automatically if it can find it
- Will now wait for certain tooltips to complete before replacing them with new ones
- `secondsRetry` changed from `5s` -> `2.5s` by default
- Fixed script error on first startup of `Premiere`
- Removed the `#+1::` hotkey to pause the script as it is no longer necessary now that the script checks to see if a save is required before proceeding