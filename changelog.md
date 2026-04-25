# <> Release 2.18.0 - Premiere 26.2+ Support
This release brings support for `Premiere 26.2+`. This required a rather extensive rewrite to all `UIA` related code and as such removes compatibility with Premiere versions prior to 26.2.  
You may notice that gathering UIA information is no longer (practically) instant; this was in large part the reason this release required my UIA related code to be rewritten from the ground up. As it can take upwards of 5-10s to generate, the UIA tree is now generated once and is then shared amongst all scripts as they require it.  

<img width="527" height="212" alt="Adobe_Premiere_Pro_X5naawl7SI_2" src="https://github.com/user-attachments/assets/ee8b9ec6-b9dd-4583-870f-9a19c47c15f6" />

## Functions
- ✅ Fixed `winget.PremName()` failing to determine `beta` titles correctly
- ✅ Fixed `settingsGUI()` not generating the proper `Premiere` shortcut when the `beta` checkbox is deselected

### 📝 `prem {`
- ❗ Support for `v26.2`
- 📋 UIA values will now be reset on Premiere close
- 📋 Changed `prem.selectionTool()` => `prem.selectTool()`
    - Can now set any tool set within `Premiere_UIA.ahk`

### 📝 `startup {`
- ✅ Fixed an issue with `updateCheckGUI.ahk` using outdated `WebView2` code and subsequently throwing
- ✅ Fixed `updateChecker()` throwing if the user attempted to download an update from the GUI

### 📝 `Settings {`
- ✏️ Added `Set_UIA_on_load`
- ❌ Removed `Always_Check_UIA`, `Set_UIA_Limit_Daily`

### 📝 `notifyExt {`
- ❗Added class `notifyExt {`
- ✏️Added `destroyDupes()`, `checkMultiple()`, `deleteIfExist()`

📍 `notifyIfNotExist()`
- 📋 Renamed `notifyIfNotExist()` => `showIfNotExist()`
- 📋 Moved function into `notifyExt {` class
- 📋 Will now send its request to be handled by `Core Functionality.ahk`
    - ✅ Fixes `Notify` windows called during `HotkeylessAHK` functions causing the script to hang if they are still active once the function has finished executing