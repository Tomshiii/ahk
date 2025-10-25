# <> Release 2.16.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated or added.

## Functions
- ✅ Fixed `slack.button()` throwing in certain circumstances
- ✅ Fixed `getHotkeysArr()` not working with scancodes/virtualkey codes
- ✅ Fixed `startup().trayMen()` not actually rerunning `HotkeylessAHK.ahk` when the user selects `reboot` and it has been closed
- ✅ Fixed `reset {` scripts not affecting all scripts
- ✅ Fixed `trimGUI {` not calculating remaining duration if ending timecode is left as `00:00:00`
- ✅ Fixed `ytdlp.download()` not defaulting to a template filename if `filename` parameter is a blank string
- ✅ Fixed `cmd.exploreAndHighlight()` failing to open the desired path
- ✏️ Added [`move.clipMouse()`](<https://old.reddit.com/r/AutoHotkey/comments/1g8uqes/need_help/lt42sh7/>)
- ✏️ Added `obj.CaretPos()`
- 📋 `switchTo.adobeProject()` will now additionally navigate to the project directory for `#32770` windows

### 📝 `prem {`
- ✅ Fixed some colours not being theme specific
- ✅ Fixed `anchorToPosition()` not working correctly in versions `25.4` and greater
- ✅ Fixed `dismissWarning()` firing on seemingly non existent windows
- ✅ Fixed `__getAllLayerButtonPos()` throwing if it couldn't find the middle divider
- ✅ Fixed `Always Check UIA` being disabled causing scripts to throw
- ✏️ Added `stopPlayback()`
- 📋 `layerSizeAdjust()` now accepts parameter `middle` to determine if you wish to adjust the middle divider instead of the track height
- 📋 `anchorToPosition()` now accepts parameter `ae` to determine if you're calling the function from After Effects or Premiere. Defaults to `false`
    - ✅ Fixes incorrect tabbing logic inside of After Effects

🔗 `gain()`
- 📋 Will now highlight the text input field in the event the gain window is already open, but a text field is not selected
- 📋 Now uses `block_ext {` instead of just `block {` to ensure a `space::` hotkey can't close the gain window before the function has completed

🔗 `__setCurrSeq()`
- 📋 Should no longer flood the line execution
- 📋 Function (alongside `swapPreviousSequence()`) now store sequence values in an array, allowing more than 2 sequences to be toggled between
    - Limit can be set within `settingsGUI()`

🔗 `toggleEnabled()`
- ✅ Fixed function failing to select the correct clips if the user released modifier keys too late
- 📋 Now accepts param `ignore`
- 📋 Now alerts the user if it attempted to interact with a transition handle (not perfect)

`__remoteFunc()`
- 📋 Will now attempt to replace any `A_Space` in `params*` with `%20`
- 📋 Will now warn the user if `PremiereRemote` is not installed or the requested function does not exist in the users `index.tsx`

### `premUIA_Values {`
🔗 `__setNewVal()`
- ✅ Fixed function sometimes leaving inputs blocked
- 📋 Will now abort if the `Save Project` window appears
- 📋 Will now use `PremiereRemote` to stop playback if available
> [!Caution]
> This function requires updated `PremiereRemote` functions.

### 📝 `discord {`
- ✅ Fixed `Unread()` sometimes throwing due to not finding the header

🔗 `button()`
- ✅ Function should now be 2-3x faster in most cases
- ✅ Fixed function throwing if not hovering a message
- ✅ Fixed `reply` not disabling the `@` ping when setting is enabled
- ✅ Fixed function incorrectly determining when the user is within a dm or a server

### 📝 `explorer {`
- ✏️ Added class `explorer {`
- ✏️ Added `cancelSearch()`
- ✏️ Added [`navigateUsingAddressbar()`](<https://github.com/ThioJoe/ThioJoe-AHK-Scripts/blob/58874c8396c714f511f91bd4f3e8bb67f4592c66/Scripts/ExplorerDialogPathSelector.ahk#L851>)
- 📋 Moved `switchTo.explorerHighlightFile()` => `highlightFile()`
- 📋 Moved `nItemsInDir()`
- 📋 Moved `selectFileInOpenWindow()`
- 📋 Moved `winget.getActiveExplorerTab()` => `getTab()`
- 📋 Moved `winget.ExplorerPath()` => `getPath()`

## Other Changes
- ❗License files are now provided for all third party libs contained within this repo <sup>[[link]](<https://github.com/Tomshiii/ahk/tree/dev/lib/Other/LICENSES>)</sup>
- ✅ Closing `HotkeylessAHK.ahk` should now be more reliable across scripts
- ✏️ Added [`LVICE_XXS.ahk`](<https://github.com/AHK-just-me/AHK2_LVICE_XXS>)
- ✏️ Added [`Array.ahk`](<https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/Array.ahk>)

🔗 `autosave.ahk`
- ✅ Fixed double saving if the user saves during the `idle` notifications
- 📋 `Notify` windows will now be destroyed if the user manually saves during a save attempt
- 📋 Will now check for and halt if `excalibur` window is open

🔗 `PremiereRemote`
- ✏️ Added `setMarker()`
- ✏️ Added `applyEffectOnAllSelectedClips()`
- ✏️ Added `listEffectsOnSelectedClip()`
- ✏️ Added `isPlaying()`
- ✏️ Added `stopPlayback()`
- ✏️ Added `startPlayback()`

🔗 `mult-dl.ahk`
###### *(v1.2.3 -> v1.2.7.2)*
- ✅ Fixed script not properly loading after installing all required packages
- ✅ Fixed script trying to get the user to reinstall required packages if they haven't rebooted their pc
- ✅ Fixed script flashing if the user pressed the `download` button without inputting a URL
- ✅ Fixed script throwing if the user closes the window before it has finished checking for updates
- 📋 Now checks for `deno` to prepare for continued `yt-dlp` support ([see here for more info](<https://github.com/yt-dlp/yt-dlp/issues/14404>))
- 📋 Now activates the GUI if the user tries to reopen the script/exe while it is already open
- 📋 `Multi` tab now uses a `ListView` to input URLs instead of an `Edit` box
- 📋 `Use cookies` is now disabled by default