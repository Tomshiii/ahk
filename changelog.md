# <> Release 2.20.x - 

## Functions
- ✏️ Added `onPath()`
- ✅ Fixed `ae.setViewerZoom()` causing `After Effects` to show an error message when in the `Layer` view
- ✅ Fixed `createShortcuts.ahk` throwing
- ✅ Fixed `startup().adobeVerOverride()` not updating values if old versions of `Premiere`/`After Effects` aren't removed
- 📋 Added `png`/`jpg`/`jpeg`/`webp` output actions to `ffmpeg().all_XtoY()`
- 📋 `settingsGUI()` will now prompt `Core Functionality.ahk` to regenerate `KSA` when the `Year` version is changed
    - Fixes scripts throwing when reloaded due to `27.0+` pathing changes within the `.kys` files
- 📋 `slack.button()` now makes use of `Toggle()`/`Invoke()`/`Expand()` `UIA` functions instead of relying on `ControlClick()`
- 📋 `rbuttonPrem.movePlayhead()` can now restore the previous `Premiere` sequence order (instead of just the individual sequence) if the active sequence changes during the save
- 📋 Moved `docker {` `Classes\docker.ahk` => `Classes\Apps\docker.ahk`
- 📋 `premUIA_Values {` functions will now automatically attempt to regenerate panel info when necessary (*ie. a panel wasn't visible during initial generation*)

### 📝 `prem {`
- ✅ Fixed `mouseDrag()` sometimes holding onto <kbd>LButton</kbd> if activated in rapid succession
- 📋 `__isUXPInstalled()` will now check that; the `ccx` extension has been installed, and that `docker` is installed
- 📋 `determineLockedTracks()` can now use `UXP` to return its object on `Premiere` versions greater than `27.1.0`
- 📋 Renamed `__remoteFunc()` => `__remoteCEP()`
- 📋 Replaced most usage of `__remoteCEP()` => `__remoteUXP()`

📍 `save()`
- 📋 Now accepts parameter `timeout`
- 📋 Can now restore the previous sequence order (instead of just the individual sequence) if the active sequence changes during the save

📍 `__remoteCEP()`/`__remoteUXP()`
- ✅ Fixed timing out during large operations
- 📋 Will now return early if certain windows are open indicating that Premiere may be busy

### 📝 `discord {`
- 📋 `button()`now makes use of `Toggle()`/`Invoke()`/`Expand()` `UIA` functions instead of relying on `ControlClick()`

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

📍 `UXP`
- ✏️ Added;  
  - `custom/`
    - `getTrackClipMediaType()`, `getAllTrackLockStates()`, `toggleTrackLocks()`
  - `shared/storeSequence/`  
    - `snapshotActiveSequence()`. `restoreActiveSequence()`
- 📋 `closeActiveSequence()` now accepts parameter `allExcept`

## Other Changes
- ❌ Removed `convert2` `Streamdeck AHK` scripts. Replaced with `HotkeylessAHK` function
- 📋 `uninstall_PremiereRemoteUXP.ahk` will now attempt to delete any stale, leftover directories
- 📋 `autosave.ahk` can now restore the previous `Premiere` sequence order (instead of just the individual sequence) if the active sequence changes during the save

🔗 `mult-dl.ahk`
###### *(v1.3.14 -> v1.5.1)*
- ❌ Removed `Single` tab
- ✅ Fixed always prompting for updates even when none were available
- 📋 `change` button will now be disabled during downloads
- 📋 Optimised startup process for a faster launch

`Multi`
- 📋 Comma delimited list of URLs added list will now work if individually encased in `"`
- 📋 Now shows progress bars
- 📋 Videos added to list will now show their video title instead of the url
    - The user can then manually adjust the title for a custom filename once downloaded