# <> Release 2.21.0 - Premiere CEP Depreciation
With this release, `Premiere` `CEP` functionality is officially depreciated in favour of `UXP`. `After Effects` will continue to use `CEP` until its `UXP` implementation has hit a similar level of implementation as `Premiere`.

## Functions
- ❗ Removed `alwaysOnTop()`, `drawBorder()`
  - Moved functionality into `topBorder {`
  - `topBorder.toggle()` *(replaces `alwaysOnTop()`)* will now ensure the border remains persistent on the selected window, even if the currently focused window changes
- ✏️ Added `onPath()`, `getSystemLocale()`, `topBorder {`
- ✅ Fixed `KSA` not generating hotkeys for the version selected in `settingsGUI()` if multiple versions are installed
- 📋 Added `png`/`jpg`/`jpeg`/`webp` output actions to `ffmpeg().all_XtoY()`
- 📋 `settingsGUI()` will now prompt `Core Functionality.ahk` to regenerate `KSA` when the `Year` version is changed
    - Fixes scripts throwing when reloaded due to `27.0+` pathing changes within the `.kys` files
- 📋 `slack.button()` now makes use of `Toggle()`/`Invoke()`/`Expand()` `UIA` functions instead of relying on `ControlClick()`
- 📋 `rbuttonPrem.movePlayhead()` can now restore the previous `Premiere` sequence order (instead of just the individual sequence) if the active sequence changes during the save
- 📋 Moved `docker {` `Classes\docker.ahk` => `Classes\Apps\docker.ahk`
- 📋 `premUIA_Values {` functions will now automatically attempt to regenerate panel info when necessary (*ie. a panel wasn't visible during initial generation*)
- 📋 `syncDirectories()` now accepts parameter `excludeDirs`

### 📝 `prem {`
- ❗ All `Premiere` functions now work with any `theme`
- ❗ `CEP` functionality is now depreciated in favour of `UXP`
- ✏️ Added `getPrefPath()`
- ❌ Removed `movePreview()`, `__remoteFunc()`
- ✅ Fixed `mouseDrag()` sometimes holding onto <kbd>LButton</kbd> if activated in rapid succession
- 📋 `__isUXPInstalled()` will now check that; the `ccx` extension has been installed, and that `docker` is installed
- 📋 `determineLockedTracks()` can now use `UXP` to return its object in `Premiere` versions greater than `27.1.0`
- 📋 Replaced all usage of `__remoteFunc()` => `__remoteUXP()`
- 📋 `__checkPremRemoteDir()` removed param `cepOrUXP`
- 📋 Will now check the installed version of `Premiere` and present a warning if the installed `Locale` isn't `en_US`

📍 `save()`
- 📋 Now accepts parameter `timeout`
- 📋 Can now restore the previous sequence order (instead of just the individual sequence) if the active sequence changes during the save

📍 `__remoteUXP()`
- ✅ Fixed timing out during large operations
- 📋 Will now return early if certain windows are open indicating that Premiere may be busy

### 📝 `ae {`
- ✅ Fixed `setViewerZoom()` causing `After Effects` to show an error message when in the `Layer` view
- 📋 Will now check the installed version of `After Effects` and present a warning if the installed `Locale` isn't `en_US`

### 📝 `ps {`
- 📋 Object is now shared through `Core Functionality.ahk`
- 📋 Will now check the installed version of `Photoshop` and present a warning if the installed `Locale` isn't `en_US`

### 📝 `discord {`
- 📋 `button()`now makes use of `Toggle()`/`Invoke()`/`Expand()` `UIA` functions instead of relying on `ControlClick()`

📍 `Unread()`
- ✅ Fixed function failing when param `which` = `"servers"`
- 📋 Now makes use of `Invoke()` `UIA` function instead of relying on `ControlClick()`

### 📝 `cmd {`
- ✅ Fixed `exploreAndHighlight()` `doubleCheck=true` not doing anything

📍 `httpGet()`
- 📋 Now accepts parameters `retries`/`timeoutMs`
    - Now reattempts retrieving the data by default under certain circumstances

### 📝 `notifyExt {`
- 📋 `deleteIfExist` now accepts params `force`, `minTime`
- 📋 `destroyDupes` now accepts param `force`

📍 `showIfNotExist()`
- ✅ Fixed always using a duration of `8` if passed in caps; ie. `DUR=`
- ✅ Fixed clicking the GUI to close it not restarting the duration
- 📋 Now passes `dga=1` to all `Notify` GUIs by default

### 📝 `PremiereRemote`
- ✏️ Added;  
  - `custom/`
    - `getTrackClipMediaType()`, `getAllTrackLockStates()`, `toggleTrackLocks()`
  - `properties/`
    - `getPrefPath()`
  - `shared/storeSequence/`  
    - `armSequenceGuard()`. `disarmSequenceGuard()`
- 📋 `closeActiveSequence()` now accepts parameter `allExcept`
- 📋 `organiseProject()` now accepts parameter `ignoreLabelIndices`

## Other Changes
- ❌ Removed `convert2` `Streamdeck AHK` scripts. Replaced with `HotkeylessAHK` function
- ✅ Fixed `uninstall.ahk` not uninstalling `AERemote`
- ✅ Fixed `createShortcuts.ahk` throwing
- ✅ Fixed `adobe fullscreen check.ahk` instantly throwing if `ksa.prem.playheadtoCursor` is unset
- ✅ Fixed `Multi-Instance Close.ahk` sometimes failing to close duplicate `determineUIA.ahk` windows
- 📋 `uninstall_PremiereRemoteUXP.ahk` will now attempt to delete any stale, leftover directories

🔗 `autosave.ahk`
- ✅ Fixed script instantly throwing if `ksa.prem.playheadtoCursor` is unset
- 📋 Can now restore the previous `Premiere` sequence order (instead of just the individual sequence) if the active sequence changes during the save

🔗 `mult-dl.ahk`
###### *(v1.3.14 -> v1.5.2)*
- ❌ Removed `Single` tab
- ✅ Fixed always prompting for updates even when none were available
- 📋 `change` button will now be disabled during downloads
- 📋 Optimised startup process for a faster launch

`Multi`
- 📋 Comma delimited list of URLs added list will now work if individually encased in `"`
- 📋 Now shows progress bars & download speed
  - Taskbar icon will show a mirrored progress bar
- 📋 Videos added to list will now show their video title instead of the url
    - The user can then manually adjust the title for a custom filename once downloaded
- 📋 Can now `pause`/`resume`/`stop`/`stop all` download(s)/reencode(s)
- 📋 Upcoming downloads can now be removed before starting