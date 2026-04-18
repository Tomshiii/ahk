# <> Release 2.17.x - 

## Functions
- ✅ Fixed additional memory leak with functions that use `ShinsImageScanClass`

### 📝 Added class `notifyExt {`
- ✏️Added `destroyDupes()`, `checkMultiple()`

📍 `notifyIfNotExist()`
- 📋 Renamed `notifyIfNotExist` => `showIfNotExist()`
- 📋 Moved function into class
- 📋 Will now send its request to be handled by `Core Functionality.ahk`
    - ✅ Fixes `Notify` windows called during `HotkeylessAHK` functions causing the script to hang if they are still active once the function has finished executing