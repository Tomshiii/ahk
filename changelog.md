# <> Release 2.20.x - 

## Functions
- ✅ Fixed `ae.setViewerZoom()` causing `After Effects` to show an error message when in the `Layer` view
- ✅ Fixed `createShortcuts.ahk` throwing
- 📋 Added `png`/`jpg`/`jpeg`/`webp` output actions to `ffmpeg().all_XtoY()`
- 📋 `settingsGUI()` will now prompt `Core Functionality.ahk` to regenerate `KSA` when the `Year` version is changed
    - Fixes scripts throwing when reloaded due to `27.0+` pathing changes within the `.kys` files

### 📝 `prem {`
- ✅ Fixed `mouseDrag()` sometimes holding onto <kbd>LButton</kbd> if activated in rapid succession
- 📋 `__isUXPInstalled()` will now check that; the `ccx` extension has been installed, and that `docker` is installed
- 📋 `determineLockedTracks()` can now use `UXP` to return its object on `Premiere` versions greater than `27.1.0`

📍 `__remoteFunc()`/`__remoteUXP()`
- ✅ Fixed timing out during large operations

### 📝 `discord {`
- 📋 `button()` now makes use of `Toggle()`/`Invoke()` `UIA` functions instead of relying on `ControlClick()`

📍 `Unread()`
- ✅ Fixed function failing when param `which` = `"servers"`
- 📋 Now makes use of `Invoke()` `UIA` function instead of relying on `ControlClick()`

### 📝 `cmd {`
📍 `httpGet()`
- 📋 Now accepts parameters `retries`/`timeoutMs`
    - Now reattempts retrieving the data by default under certain circumstances

### 📝 `notifyExt {`
📍 `showIfNotExist()`
- ✅ Fixed always using a duration of `8` if passed in caps; ie. `DUR=`
- ✅ Fixed clicking the GUI to close it not restarting the duration

### 📝 `PremiereRemote`
- ✏️ Added `getAllTrackLockStates()`, `toggleTrackLocks()`

## Other Changes
- ❌ Removed `convert2` `Streamdeck AHK` scripts. Replaced with `HotkeylessAHK` function
- 📋 `uninstall_PremiereRemoteUXP.ahk` will now attempt to delete any stale, leftover directories

🔗 `mult-dl.ahk`
###### *(v1.3.14 -> v1.5.0)*
- ❌ Removed `Single` tab
- ✅ Fixed always prompting for updates even when none were available
- 📋 `change` button will now be disabled during downloads
- 📋 Optimised startup process for a faster launch

`Multi`
- 📋 Comma delimited list of URLs added list will now work if individually encased in `"`
- 📋 Now shows progress bars
- 📋 Videos added to list will now show their video title instead of the url
    - The user can then manually adjust the title for a custom filename once downloaded