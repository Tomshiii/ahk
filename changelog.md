# <> Release 2.17.0 - Core Functionality.ahk & Premiere v26 Support
This update introduces some rather large, breaking changes to the functionality of my scripts;
- ❗ __NO MORE SYMLINKS!__
    - This should make installation as well as maintainance far easier for the user.
    - ⚠️ `Lib` files will now be installed to `A_Appdata \tomshi\Lib`
    - ⚠️ Adobe `ImageSearch` folders are now based off my `json` files and as such no longer need to generate individual symlinks per folder
- ❗ Introducing `Core Functionality.ahk`
    - This allows my scripts to share `objects` (ie. `UserSettings`, `prem`, etc) between each other easily and safety via `Mutex` locking. This script __*MUST*__ run before any other scripts.

> [!Caution]
> ###### It is recommended for this release that the user does a completely fresh install of my scripts.

> [!Warning]
> The user will need to ensure they have manually set their `Premiere`/`After Effects` year versions to `2026` within `settingsGUI()` if they have updated from `2025`. The automatic version detection only works for the currently set year. Many functions will fail (including `PremiereRemote`) if the incorrect year version is set.

***

## Functions
- ✅ Fixed compatibility with `Premiere v26.0+` after name change
- ✅ Fixed multiple instances of incorrect `||` logic
- ✅ Fixed `getHotkeysArr()` not working with scancodes/virtualkey codes
- ✅ Fixed `ytdlp.download()` not defaulting to a template filename if `filename` parameter is a blank string
- ✅ Fixed `cmd.exploreAndHighlight()` failing to open the desired path
- ✅ Fixed `loadXML()` throwing in the event the file is busy
- 📋 Added minor usage of `Critical()` across core functions to minimise instances where functions are interrupted during key operations
- 📋 Replaced all usage of `WinGetTitle("A")` with `WinGet.Title()` to avoid unnecessary instances of scripts throwing
- 📋 `KeyShortAdjust {` hotkeys may now include <kbd>=</kbd> or <kbd>"</kbd> for... whatever reason that you'd need that
- 📋 `syncDirectories()` will now work with network drives
- ✏️ Added `isBool()`, `checkBool()`, `delayFuncs()`, `runExt()`, `validateTypes()`, `notifyIfNotExist()`
- ✏️ Added `CLSID_Objs {`
    - Allows for objects to be shared between scripts easily

### 📝 `prem {`
- ✅ Fixed some colours not being theme specific
- ✅ Fixed `__setTimelineCol()` throwing if the user sets a Premiere version below `25.0`
- ✅ Fixed `dismissWarning()` firing on seemingly non existent windows
- ✅ Fixed `__getAllLayerButtonPos()` throwing if it couldn't find the middle divider
- ✅ Fixed `Always Check UIA` being disabled causing scripts to throw
- ✅ Fixed `selectionTool()` containing left over code
- ✅ Fixed potential memory leak while using `isEditTabActive()`, especially in timers
- ✏️ Added `stopPlayback()`, `startPlayback()`, `deleteEmptyTracks()`, `__resetTimelineVals()`, `renderProjectSelection()`
- ✏️ Added `__disableMulticamOnAudioEffect()` to handle toggling the `Multi-Cam View` if an audio effect window becomes active
- ✏️ Added `checkRemote()`
    - `prem {` calls this function on a timer to poll for the `PremiereRemote` window to ensure `__remoteFunc()` will not fire if the window is closed
- ✏️ Added `toggleLinearColour()`
    - ❌ Removed `toggleLinearColour.ahk`
- 📋 Renamed `Previews()` => `deletePreviews()` and removed parameter `which`
    - ✏️ Added `renderPreviewsInOut()`
- 📋 `disableAllMuteSolo()` & `soloVideo()` can now use `PremiereRemote` to reenable all video tracks & unmute all muted audio tracks
- 📋 `closeActiveSequence()` now accepts parameter `allExcept` to close all *except* the active sequence
- 📋 Now polls the `PremiereRemote` socket on a timer so that `__remoteFunc()` can abort early if it isn't open
    - It should be noted this is checking the default port of `8081`. If you change `PremiereRemote`'s port, you will need to change the port `Prem {` is checking as well

📍 `save()`
- 📋 Will now abort early if `Premiere` fails to retrieve the originally active sequence
- 📋 Now uses `WinEvent` to capture if the `Save Project` window appears/closes
    - ✅ Fixes instances of `WinWait()` missing the window and causing the function to timeout

📍 `gain()`
- 📋 Will now highlight the text input field in the event the gain window is already open, but a text field is not selected
- 📋 Now uses `block_ext {` instead of just `block {` to ensure a `space::` hotkey can't close the gain window before the function has completed

📍 `__setCurrSeq()`
- 📋 Should no longer flood the line execution
- 📋 Now stores sequence values in an array, allowing more than 2 sequences to be toggled between (alongside `swapPreviousSequence()`) 
    - Limit can be set within `settingsGUI()`

📍 `toggleEnabled()`
- ✅ Fixed function failing to select the correct clips if the user released modifier keys too late
- 📋 Now accepts param `ignore`
- 📋 Now alerts the user if it attempted to interact with a transition handle (not perfect)
- 📋 Now alerts the user if selected track is greater than the users `Ignore` (+ `Offset`) value

📍 `__remoteFunc()`
- ✅ Fixed function failing to pass `&` in `params*` parameters
- 📋 Will now attempt to replace any `A_Space` in `params*` with `%20`
- 📋 Will now warn the user if `PremiereRemote` is not installed or the requested function does not exist in the user's `index.tsx`
- 📋 Will now halt early if Premiere hasn't opened a project yet
- 📋 Will now halt early if a socket connection doesn't exist

📍 `layerSizeAdjust()`
- 📋 Now accepts parameter `middle` to determine if the user wishes to adjust the middle divider instead of the individual track height
- 📋 Now alerts the user if it has had to focus the timeline so they may reactivate the hotkey to proceed

📍 `anchorToPosition()`
- ✅ Fixed function not working correctly in versions `25.4` and greater
- 📋 Now accepts parameter `ae` to determine if you're calling the function from After Effects or Premiere. Defaults to `false`
    - ✅ Fixes incorrect tabbing logic inside of After Effects

📍 `dragSourceMon()`
- 📋 Parameter `specificFile` now requires a full path to the desired file
- 📋 Now accepts parameter `searchForFile` which, when set, will attempt to search for the desired file if it isn't already loaded in the source monitor

### 📝 `premUIA_Values {`
- ✅ Fixed duplicate `Notify {` windows being spammed during errors
- 📋 Renamed `effectsControl` => `effectControls`

📍 `__setNewVal()`
- ✅ Fixed function sometimes leaving inputs blocked
- 📋 Will now abort if the `Save Project` window appears
- 📋 Will alert the user if their set version of Premiere does not match the open application

### 📝 `settingsGUI()`
- ✅ Fixed version dropdown lists not being sorted in numerical order
- ✅ Fixed changing `Premiere`/`After Efects` year versions not generating new shortcuts
- ✅ Fixed interacting with `beta` checkbox throwing
- 📋 `Photoshop` has been removed from version selection due to differing criteria and not being relevant or required since implementation
    - 📋 Shortcuts will now generate for the latest non beta of Photoshop (unless only a Beta version is installed)

### 📝 `reset {`
- ✅ Fixed functions not affecting all scripts
- ✅ Fixed functions throwing when encountering scripts with no path in the title

### 📝 `discord {`
- ✅ Fixed `Unread()` sometimes throwing due to not finding the header

📍 `button()`
- ✅ Function should now be 2-3x faster in most cases
- ✅ Fixed function throwing if not hovering a message
- ✅ Fixed `reply` not disabling the `@` ping when setting is enabled
- ✅ Fixed function incorrectly determining when the user is within a dm or a server

### 📝 `slack {`
📍 `button()`
- ✅ Function should now be 2-3x faster in most cases
- ✅ Fixed function throwing in certain circumstances
- ✅ Fixed `"edit"` & `"delete"` no longer working
- ✅ Fixed function failing while a thread is open
- ✅ Fixed `"reaction"` attempting to interact with the icon under image messages

### 📝 `winExt {`
- ✏️ Added class `winExt {`
- ✏️ Added `Regex()` functions to cut repeat code
    - `TitleRegex()`, `ClassRegex()`, `ActiveRegex()`, `ActivateRegex()`, `CloseRegex()`, `ExistRegex()`, `CountRegex()`, `PIDRegex()`, `ProcessNameRegex()`, `ListRegex()`, `WaitCloseRegex()`, `WaitRegex()`, `MinimizeRegex()`, `MaximizeRegex()`

### 📝 `WinGet {`
- ✅ Fixed all instances of `Title()` causing scripts to throw
- ✅ Fixed `__AdobeName()` `titleCheck` always returning `true`
- ✅ Fixed `__determineAdobeYear()` ignoring the year in an `After Effects` title
- 📋 Renamed `ID()` => `PID()`
    - ❗Now returns the `PID` instead of the `ProcessName`

### 📝 `explorer {`
- ❗ Added class `explorer {`
- ✏️ Added `cancelSearch()`
- ✏️ Added [`navigateUsingAddressbar()`](<https://github.com/ThioJoe/ThioJoe-AHK-Scripts/blob/58874c8396c714f511f91bd4f3e8bb67f4592c66/Scripts/ExplorerDialogPathSelector.ahk#L851>)
- 📋 Moved `switchTo.explorerHighlightFile()` => `highlightFile()`
- 📋 Moved `nItemsInDir()`
- 📋 Moved `selectFileInOpenWindow()`
- 📋 Moved `winget.getActiveExplorerTab()` => `getTab()`
- 📋 Moved `winget.ExplorerPath()` => `getPath()`

### 📝 `obj {`
- ✅ Fixed all instances of `MousePos()` & `WinPos()` causing scripts to throw
- ✏️ Added `CaretPos()`

### 📝 `startup {`
- ✅ Fixed `__checkForReloadAttempt()` causing scripts to throw under certain circumstances
- ✅ Fixed `Set Prem_UIA Values` not working when selected from the tray menu
- ✅ Fixed `checkVersJSON()` generating broken `.json` files
- 📋 `gitBranchCheck()` will now abort if the user has any stashed changes

📍 `trayMen()`
- ✅ Fixed function not actually rerunning `HotkeylessAHK.ahk` when the user selects `reboot` and it has already been closed
- ✅ Fixed function potentially leaking `detect` settings
- ✅ Fixed function potentially getting stuck if another process changes the current `detect` settings while function is operating

📍 `adobeVerOverride()`
- ✅ Fixed function not generating new shortcuts
- ✅ Fixed function failing to retrieve file version if system language isn't set to `English`

### 📝 `switchTo {`
📍 `adobeProject()`
- ✅ Fixed function throwing if the taskbar is the active window
- 📋 Will now additionally navigate to the project directory for `#32770` windows

### 📝 `errorLog {`
- ✅ Fixed occasionally skipping the timestamp for the first error of the day
- 📋 If the error originates from a `Hotkey` and not a function, the log will now show the hotkey (ie. `<HotKey>` => `z::`)

### 📝 `move {`
- ✏️ Added [`clipMouse()`](<https://old.reddit.com/r/AutoHotkey/comments/1g8uqes/need_help/lt42sh7/>)
- ❌ Removed `Tab()`

### 📝 `trimGUI {`
- ✅ Fixed script not calculating remaining duration if ending timecode is left as `00:00:00`
- ✅ Fixed script continuing if both timecodes are identical

### 📝 `PS {`
📍 `Type()`
- 📋 Will now move the cursor out of the way so it doesn't cause the function to click the incorrect option
- 📋 Will now refocus the filename field after selecting the filetype

## Other Changes
- ❗License files are now provided for all third party libs contained within this repo <sup>[[link]](<https://github.com/Tomshiii/ahk/tree/dev/lib/Other/LICENSES>)</sup>
- ✅ Closing `HotkeylessAHK.ahk` should now be more reliable across scripts
- 📋 Reduced the usage of `Exit()` across the entire repo to minimise potential instances of inputs getting stuck
- 📋 Placed most usage of `detect()` within `Critical()` blocks to avoid instances of changes leaking over to other functions
- ✏️ Added `uninstall.ahk`
- ✏️ Added [`LVICE_XXS.ahk`](<https://github.com/AHK-just-me/AHK2_LVICE_XXS>), [`Array.ahk`](<https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/Array.ahk>), [`Mutex.ahk`](<https://github.com/Nich-Cebolla/AutoHotkey-Interprocess-Communication/blob/main/src/Mutex.ahk>), [`socket.ahk`](<https://github.com/TheArkive/Socket_ahk2/blob/master/_socket.ahk>)
- ❌ Removed `screenshot` `Streamdeck AHK` scripts and all related functions
- ❌ Removed `autodismiss error.ahk`. Adobe finally added a toggle to disable the warning

🔗 `Premiere_RightClick.ahk`
- ✅ Fixed script throwing in `ahk v2.0.20`
- ✅ Fixed `checkStuck()` sometimes appearing after the user saves
- ✅ Fixed script stalling if `PremiereRemote` is closed

🔗 `autosave.ahk`
-❗ Fixed memory leak issue caused by `prem.isEditTabActive()` (see above)
- ✅ Fixed double saving if the user saves during the `idle` notifications
- ✅ Fixed inputs getting stuck blocked in certain circumstances
- ✅ Fixed `After Effects` getting stuck transparent when saved in the background
- ✅ Fixed `After Effects` never saving in certain circumstances where `__checkDialogueClass()` always returned `false`
- ✅ Fixed `After Effects` being send to the bottom of the window stack if `Mocha` is open
- ✅ Fixed retrieving title logic causing scripts to throw in some scenarios
- 📋 `Notify` windows will now be destroyed if the user manually saves during a save attempt
- 📋 Will now check for and halt if `excalibur` window is open
- 📋 Will now use `CEP` to save `After Effects` instead of needing keystrokes

🔗 `PremiereRemote`
- ✏️ Added;  
     `applyEffectOnAllSelectedClips()`, `isPlaying()`, `listEffectsOnSelectedClip()`, `loadInSourceMonitor()`, `moveToAssetsBin()`, `premVer()`, `renderPreviews()`, `searchForBinWithName()`, `searchForItemByName()`, `setMarker()`, `stopPlayback()`, `startPlayback()`, `togglePlayback()`, `enableAllVideoTracks()`, `unmuteAllMutedTracks()`, `getClipTrackIndex()`, `renderInPrem()`, `importFile()`, `selectionIsSequence()`, `closeClipSourceMon()`, `closeAllClipSourceMon()`
- ❌ Removed `setBarsAndTone()`
- 📋 `saveProj()` now properly returns whether it suceeded or failed
- 📋 `closeActiveSequence()` now accepts parameter `allExcept` to close all *except* the active sequence


📍 `toggleLinearColour()`
- ✅ Fixed function causing `Premiere` to crash if sequence settings are reopened after toggling
- 📋 Now accepts parameter `enableMaxRenderQual`

🔗 `Keyboard Shortcuts.ini`
- ✅ Fixed `premRippleDelete` command (`cmd.timeline.ripple.delete` => `cmd.edit.rippledelete`). May have changed after a premiere update
- ✏️ Added `fitToFrame`, `selectedClipStart`, `selectedClipEnd`, `stepBackOneFrame`, `stepForwardOneFrame`, `deleteEmptyTracksAll`, `toggleMultiCam`

🔗 `adobeKSA`
- ✅ Fixed script not loading Premiere xml file correctly
- ✏️ Added additional known `<virtualkey>` values to make process more reliable
- 📋 Split out `adobeXML {` into its own class

🔗 `mult-dl.ahk`
###### *(v1.2.3 -> v1.3.5)*
- ✅ Fixed script not properly loading after installing all required packages
- ✅ Fixed script trying to get the user to reinstall required packages if they haven't rebooted their pc
- ✅ Fixed script flashing if the user pressed the `download` button without inputting a URL
- ✅ Fixed script throwing if the user closes the window before it has finished checking for updates
- ✅ Fixed `Check dev branch` checkbox getting stuck disabled if the user doesn't update packages
- ✏️ Rudimentary youtube playlist support
- ✏️ Add `Show Download Folder` button
- 📋 Now checks for `deno` for continued `yt-dlp` support ([see here for more info](<https://github.com/yt-dlp/yt-dlp/issues/14404>))
- 📋 Now activates the GUI if the user tries to reopen the script/exe while it is already open
- 📋 Now remembers previous download locations
- 📋 `Multi` tab now uses a `ListView` to input URLs instead of an `Edit` box
- 📋 `Use cookies` is now disabled by default
- 📋 `Multi` downloads will now sleep anywhere from `18s` to `26s` between each download to reduce the risk of being flagged by youtube as a bot
- 📋 `dev` branch is now checked for updates by default and previously set state will be remembered
- 📋 `.exe` will now check for version updates on startup

***

> [!Warning]
> There are still a few known issues with this release.  
> It is recommended to check out the [`Known Issues & Planned Changes`](<https://github.com/users/Tomshiii/projects/1/views/1>) page if you are encountering any issues.  
> If you are encountering an issue and it is not listed, consider creating an [Issue](<https://github.com/Tomshiii/ahk/issues>) so it can be tracked.