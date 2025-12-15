# <> Release 2.16.x - 

> [!Warning]
> There are still a few known issues with this release.  
> It is recommended to check out the [`Known Issues & Planned Changes`](<https://github.com/users/Tomshiii/projects/1/views/1>) page if you are encountering any issues.  
> If you are encountering an issue and it is not listed, consider creating an [Issue](<https://github.com/Tomshiii/ahk/issues>) so it can be tracked.

> [!Caution]
> ###### If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated or added.

## Functions
- ✅ Fixed multiple instances of incorrect `||` logic
- ✅ Fixed `getHotkeysArr()` not working with scancodes/virtualkey codes
- ✅ Fixed `reset {` functions not affecting all scripts
- ✅ Fixed `ytdlp.download()` not defaulting to a template filename if `filename` parameter is a blank string
- ✅ Fixed `cmd.exploreAndHighlight()` failing to open the desired path
- ✅ Fixed version dropdown lists in `settingsGUI()` not being sorted in numerical order
- ✅ Fixed `errorLog()` sometimes skipping the timestamp for the first error of the day
- ✅ Fixed `loadXML()` throwing in the event the file is busy
- 📋 Added minor usage of `Critical()` across core functions to minimise instances where functions are interrupted during key operations
- 📋 Replaced all usage of `WinGetTitle("A")` with `WinGet.Title()` to avoid unnecessary instances of scripts throwing
- ✏️ Added `isBool()`/`checkBool()`

### 📝 `prem {`
- ✅ Fixed some colours not being theme specific
- ✅ Fixed `dismissWarning()` firing on seemingly non existent windows
- ✅ Fixed `__getAllLayerButtonPos()` throwing if it couldn't find the middle divider
- ✅ Fixed `Always Check UIA` being disabled causing scripts to throw
- ✏️ Added `stopPlayback()`
- ✏️ Added `startPlayback()`
- ✏️ Added `toggleLinearColour()`
- ✏️ Added `renderPreviewsInOut()`
    - 📋 Renamed `Previews()` => `deletePreviews()` and removed parameter `which`
- 📋 `layerSizeAdjust()` now accepts parameter `middle` to determine if the user wishes to adjust the middle divider instead of the individual track height
- 📋 `dragSourceMon()` now accepts parameter `searchForFile` which, when set, will attempt to search for the desired file if it isn't already loaded in the source monitor

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

📍 `__remoteFunc()`
- ✅ Fix function failing to send `&` in paramaters
- 📋 Will now attempt to replace any `A_Space` in `params*` with `%20`
- 📋 Will now warn the user if `PremiereRemote` is not installed or the requested function does not exist in the user's `index.tsx`

📍 `anchorToPosition()`
- ✅ Fixed function not working correctly in versions `25.4` and greater
- 📋 Now accepts parameter `ae` to determine if you're calling the function from After Effects or Premiere. Defaults to `false`
    - ✅ Fixes incorrect tabbing logic inside of After Effects

### 📝 `premUIA_Values {`
📍 `__setNewVal()`
- ✅ Fixed function sometimes leaving inputs blocked
- 📋 Will now abort if the `Save Project` window appears
- 📋 Will alert the user if their set version of Premiere does not match the open application

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

### `WinGet {`
- ✅ Fixed all instances of `Title()` causing scripts to throw
- ✏️ Added `Regex()` functions to cut repeat code
    - `TitleRegex()`, `ClassRegex()`, `ActiveRegex()`, `ActivateRegex()`, `CloseRegex()`, `ExistRegex()`, `CountRegex()`, `PIDRegex()`, `ProcessNameRegex()`, `ListRegex()`, `WaitCloseRegex()`, `WaitRegex()`
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
- ✅ Fixed `checkVersJSON()` generating an entry even if an `ImageSearch` folder exists
- 📋 `gitBranchCheck()` will now abort if the user has any stashed changes

📍 `trayMen()`
- ✅ Fixed function not actually rerunning `HotkeylessAHK.ahk` when the user selects `reboot` and it has already been closed
- ✅ Fixed function potentially leaking `detect` settings
- ✅ Fixed function potentially getting stuck if another process changes the current `detect` settings while function is operating

### 📝 `switchTo {`
📍 `adobeProject()`
- ✅ Fixed function throwing if the taskbar is the active window
- 📋 Will now additionally navigate to the project directory for `#32770` windows

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
- 📋 Reduced the usage of `Exit()` across the entire repo to minimise potential instances of inputs getting stuck
- 📋 Placed most usage of `detect()` within `Critical()` blocks to avoid instances of changes leaking over to other functions
- ✅ Closing `HotkeylessAHK.ahk` should now be more reliable across scripts
- ✏️ Added [`LVICE_XXS.ahk`](<https://github.com/AHK-just-me/AHK2_LVICE_XXS>)
- ✏️ Added [`Array.ahk`](<https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/Array.ahk>)
- ❌ Removed `toggleLinearColour.ahk`

🔗 `autosave.ahk`
> [!Warning]
> I am aware of a bug with `autosave.ahk` causing its memory usage to slowly climb. While I am not currently sure of the cause, it is actively being investigated and a fix should hopefully be implemented by the next release. You can track the status of this bug [here](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=134206373>)
- ✅ Fixed double saving if the user saves during the `idle` notifications
- ✅ Fixed inputs getting stuck blocked in certain circumstances
- ✅ Fixed `After Effects` getting stuck transparent when saved in the background
- ✅ Fixed `After Effects` never saving in certain circumstances where `__checkDialogueClass()` always returned `false`
- ✅ Fixed `After Effects` being send to the bottom of the window stack if `Mocha` is open
- 📋 `Notify` windows will now be destroyed if the user manually saves during a save attempt
- 📋 Will now check for and halt if `excalibur` window is open
- 📋 Will now use `CEP` to save `After Effects` instead of needing keystrokes

🔗 `PremiereRemote`
- ✏️ Added;  
     `applyEffectOnAllSelectedClips()`, `isPlaying()`, `listEffectsOnSelectedClip()`, `loadInSourceMonitor()`, `moveToAssetsBin()`, `premVer()`, `renderPreviews()`, `searchForBinWithName()`, `searchForItemByName()`, `setMarker()`, `stopPlayback()`, `startPlayback()`, `togglePlayback()`
- ❌ Removed `setBarsAndTone()`
- 📋 `saveProj()` now properly returns whether it suceeded or failed

📍 `toggleLinearColour()`
- ✅ Fixed function causing `Premiere` to crash if sequence settings are reopened after toggling
- 📋 Now accepts parameter `enableMaxRenderQual`

🔗 `adobeKSA`
- ✅ Fixed script not loading Premiere xml file correctly
- ✏️ Added additional known `<virtualkey>` values to make process more reliable
- 📋 Split out `adobeXML {` into its own class

🔗 `mult-dl.ahk`
###### *(v1.2.3 -> v1.2.9)*
- ✅ Fixed script not properly loading after installing all required packages
- ✅ Fixed script trying to get the user to reinstall required packages if they haven't rebooted their pc
- ✅ Fixed script flashing if the user pressed the `download` button without inputting a URL
- ✅ Fixed script throwing if the user closes the window before it has finished checking for updates
- 📋 Now checks for `deno` to prepare for continued `yt-dlp` support ([see here for more info](<https://github.com/yt-dlp/yt-dlp/issues/14404>))
- 📋 Now activates the GUI if the user tries to reopen the script/exe while it is already open
- 📋 `Multi` tab now uses a `ListView` to input URLs instead of an `Edit` box
- 📋 `Use cookies` is now disabled by default
- 📋 `Multi` downloads will now sleep anywhere from `18s` to `26s` between each download to reduce the risk of being flagged by youtube as a bot