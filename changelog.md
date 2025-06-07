# <> Release 2.15.x - 

## Functions
- ✅ Fixed `disc.button("edit")` throwing if the user hovers over a message that isn't theirs
- ✏️ Added `FormatWeekRange()`
- ✏️ Added `getDaySuffix()`
- 📋 `clip.returnClip()` & `clip.delayReturn()` now accept parameter `clearClipboard` to determine whether the clipboard should initially be cleared before attempting to return the stored clipboard. Defaults to `true`
- 📋 `premUIA_Values {` will now alert the user if it fails to create the same amount of controls as defined within the class

⚠️ `prem {`
- ✅ Fixed `layerSizeAdjust()` not initially moving the mouse instantly
- ✏️ Added `disableAllMuteSolo()`
