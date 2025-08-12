# <> Release 2.16.x - 

## Functions
- ✅ Fixed `keys.allWait()` stopping a hotkey too early
- ✅ Fixed `getHotkeys()` incorrectly returning boolean `false` in some circumstances

⚠️ `getHotkeysArr()`
- ✅ Fixed function returning <kbd><!</kbd> as `<` & `!` instead of as one hotkey
- ✅ Fixed function being case sensitive when it shouldn't have been
- 📋 Will now return all hotkeys as `vk` values instead of a mix of `vk` and regular strings

⚠️ `prem {`
- ✏️ Added `changeDupeFrameMarkers()`

📍 `toggleEnabled()`
- ✏️ Now accepts parameter `allExcept` to toggle all tracks *except* the desired track
- 📋 Can now instantly change multiple tracks if the user places the activation hotkeys correctly. (see the [wiki for more info](<https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#premtoggleenabled>))