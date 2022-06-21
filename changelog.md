# <> Release 2.4.x - 

## > My Scritps
- `updateChecker()` will now wait for previous tooltips to complete before moving forward in the event that the user has selected "do not prompt"
- `#c` will now make a slightly larger window if the active window is a youtube window
- `RAlt & p` now has the ability to *only* move the `Project` window to it's proper position

## > Functions
- `switchToAE()` now able to find `.aep` file for the current working project regardless of name

`gain()`
- Fixed function waiting for window `off` to close instead of the proper `Audio Gain` window
- Removed code relating to `DroverLord - Window Class3` as the timeline isn't the only panel that can take on this Window Class, rendering the code detrimental on some occasions

`audioDrag()`
- Now shows a tooltip alerting the user it's waiting for an input before continuing
- Now has added functionality to not move the cut `bleep` sfx to track 1 if the user presses `c` while the function is waiting for the user to cut the sfx

## > Other Changes
- Fixed comments in `Keyboard Shortcut Adjustments.ahk` that had been copy/pasted but never corrected
- `autodismiss error.ahk` will now ignore the `Clip Mismatch Warning` dialog that can appear in Premiere when you drag a clip to the timeline that doesn't match the sequence settings

`autosave.ahk`
- Will now timeout after 3s if it gets stuck while attempting to save
- Will now check to make sure the user has opened the `checklist.ahk` file for the current project. It will also attempt to open it automatically if it can find it
    - The code to automatically open the checklist of the open project moved from `QMK.ahk` to `\Functions\Premiere.ahk` -> `openChecklist()`
- Will now wait for certain tooltips to complete before replacing them with new ones