# <> Release 2.16.x - 

## Functions
- ✅ Fixed `keys.allWait()` stopping a hotkey too early
- ✅ Fixed `getHotkeys()` incorrectly returning boolean `false` in some circumstances
- ✏️ `prem.toggleEnabled()` now accepts parameter `allExcept` to toggle all tracks *except* the desired track

⚠️ `getHotkeysArr()`
- ✅ Fixed function returning <kbd><!</kbd> as `<` & `!` instead of as one hotkey
- ✅ Fixed function being case sensitive when it shouldn't have been
- 📋 Will now return all hotkeys as `vk` values instead of a mix of `vk` and regular strings