# <> Release 2.17.x - 

## Functions
- ✅ Fixed `winget.PremName()` failing to determine `beta` titles correctly

### 📝 `prem {`
- 📋 UIA values will now be reset on Premiere close
- 📋 Changed `prem.selectionTool()` => `prem.selectTool()`
    - Can now set any tool set within `Premiere_UIA.ahk`

### 📝 `startup {`
- ✅ Fixed an issue with `updateCheckGUI.ahk` using outdated `WebView2` code and subsequently throwing
- ✅ Fixed `updateChecker()` throwing if the user attempted to download an update from the GUI

### 📝 Added class `notifyExt {`
- ✏️Added `destroyDupes()`, `checkMultiple()`, `deleteIfExist()`

📍 `notifyIfNotExist()`
- 📋 Moved function into `notifyExt {` class
- 📋 Will now send its request to be handled by `Core Functionality.ahk`
    - ✅ Fixes `Notify` windows called during `HotkeylessAHK` functions causing the script to hang if they are still active once the function has finished executing