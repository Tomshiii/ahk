# <> Release 2.12.x - 
It is now possible to mark versions of `After Effects` & `Premiere Pro` as `Beta` within `settingsGUI()` to bring compatibility to the beta versions of both programs.

## > autosave.ahk
- Attempted to fix `autosave.ahk` infrequently throwing
- Fix `__fallback()` attempting to call non existent variable `this.__checkPlayback` instead of the function `this.__checkPlayback()`

## > Other Changes
- Added `;SubUnderHotkey;`
- Added `generateAdobeSym.ahk`
- `;numpadytHotkey;` will no longer block inputs in `YouTube Studio`
- If `After Effects` **isn't** open, `sendToAE.ahk` will now ask the user if they wanted to open an existing AE project or create a new one.