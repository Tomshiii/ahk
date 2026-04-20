# <> Release 2.17.x - 

### 📝 `startup {`
- ✅ Fixed an issue with `updateCheckGUI.ahk` using outdated `WebView2` code and subsequently throwing
- ✅ Fixed `updateChecker()` throwing if the user attempted to download an update from the GUI

### 📝 Added class `notifyExt {`
- ✏️Added `destroyDupes()`, `checkMultiple()`

📍 `notifyIfNotExist()`
- 📋 Moved function into `notifyExt {` class
- 📋 Will now send its request to be handled by `Core Functionality.ahk`
    - ✅ Fixes `Notify` windows called during `HotkeylessAHK` functions causing the script to hang if they are still active once the function has finished executing