# <> Release 2.4.x - 

## > My Scritps
- `updateChecker()` will now wait for previous tooltips to complete before moving forward in the event that the user has selected "do not prompt"

## > Functions
- `switchToAE()` now able to find `.aep` file for the current working project regardless of name
- `audioDrag()` now shows a tooltip alerting the user it's waiting for an input before continuing

## > Other Changes
- `autosave.ahk` will now timeout after 3s if it gets stuck while attempting to save
- Fixed comments in `Keyboard Shortcut Adjustments.ahk` that had been copy/pasted but never corrected
- `autodismiss error.ahk` will now ignore the `Clip Mismatch Warning` dialog that can appear in Premiere when you drag a clip to the timeline that doesn't match the sequence settings