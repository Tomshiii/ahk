# <> Release 2.12.x - 
- It is now possible to mark versions of `After Effects` & `Premiere Pro` as `Beta` within `settingsGUI()` to bring compatibility to the beta versions of both programs.
- Removed use of `_DLFile.ahk` to allow `startup.updateChecker()` & `startup.updateAHK()` to function correctly

## > Functions
- `settingsGUI()` will now produce a TrayTip when closed to visually show that changes are being saved
- `tool.wait()` will no longer infinitly wait for the `Startup {` tooltips

## > autosave.ahk
- Attempted to fix `autosave.ahk` infrequently throwing
- Fix `__fallback()` attempting to call non existent variable `this.__checkPlayback` instead of the function `this.__checkPlayback()`

## > Other Changes
- Added `;SubUnderHotkey;`
- Added `generateAdobeSym.ahk`
- `;numpadytHotkey;` will no longer block inputs in `YouTube Studio`
- If `After Effects` **isn't** open, `sendToAE.ahk` will now ask the user if they wanted to open an existing AE project or create a new one.