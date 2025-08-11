# <> Release 2.16.x - 

## Functions
- ✅ Fixed `keys.allWait()` stopping a hotkey too early
- ✅ Fixed `getHotkeys()` incorrectly returning boolean `false` in some circumstances

⚠️ `getHotkeysArr()`
- ✅ Fixed function returning `<!` as `<` & `!` instead of as one hotkey
- 📋 Will now return all hotkeys as `vk` values instead of a mix of `vk` and regular strings