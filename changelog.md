# <> Release 2.15.x - 

## Functions
- ✅ Fixed `disc.button("edit")` throwing if the user hovers over a message that isn't theirs
- ✏️ Added `FormatWeekRange()`
- ✏️ Added `FormatWeekDay()`
- ✏️ Added `getDaySuffix()`
- 📋 `clip.returnClip()` & `clip.delayReturn()` now accept parameter `clearClipboard` to determine whether the clipboard should initially be cleared before attempting to return the stored clipboard. Defaults to `true`
- 📋 `premUIA_Values {` will now alert the user if it fails to create the same amount of controls as defined within the class

⚠️ `prem {`
- ✅ Fixed `layerSizeAdjust()` not initially moving the mouse instantly
- ✏️ Added `disableAllMuteSolo()`

📍 `prem.save()`
- 📋 Now accepts parameter `continueOnBusy`
- 📋 Will now return `"busy"` in the event that a window with a different class value has the current focus. *(parameter `continueOnBusy` must be set to `false`)*

## Other Changes
- ✏️ Added `generateProxies.ahk`
- `ExplorerDialogPathSelector.ahk` will no longer add its own tray menu item
- `autosave.ahk` will now no longer continue a `Premiere` save attempt when the `save` function determines Premiere may be busy to stop instances where saving may get stuck