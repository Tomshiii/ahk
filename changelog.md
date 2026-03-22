# <> Release 2.17.1 - 
This update is designed with the philosophy of removing any files the user is expected to modify out of the source directories, allowing for the installer process to simply replace the current install instead of requiring a fresh install.

## Functions
- ✏️ Added `checkINI()`

### 📝 `UserPref {`
- ❌ Removed `MainScriptName`
- 📋 Will now check the user's `.ini` file against a fresh template during the `Core Functionality.ahk` initialisation flow

## Other Changes
- ❌ Removed `Streamdeck_opt.ahk`
- ❌ Removed `..\Support Files\Streamdeck Files`
- ❌ Removed `..\Streamdeck AHK\run & activate`

### 📝 `KSA`
- 📋 Moved the active `Keyboard Shortcuts.ini` file to `A_MyDocuments \tomshi\Keyboard Shortcuts.ini`
    - 📋 Moved the template file from `..\Support Files\KSA` => `A_AppData\tomshi\lib\KSA`
    - 📋 Will check the user's current ini file against the template 