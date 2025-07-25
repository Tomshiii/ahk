# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `getHotkeys()` not handling hotkeys that discern either the left or right pair (eg. <kbd><!2</kbd>)
- ✅ Fixed `settingsGUI()` throwing when trying to adjust some checkboxes
- ✏️ Added `cmd.exploreAndHighlight()`
- ✏️ Added `selectFileInOpenWindow()`
- ✏️ Added [`nItemsInDir()`](<https://www.autohotkey.com/boards/viewtopic.php?p=494290#p494290>)
- 📋 Moved `timelineColours {` out of `Premiere_RightClick.ahk` and into its own file

⚠️ `ffmpeg {`
- ✏️ Added `isVideo()`
- 📋 Alert tooltip on completion can now be silenced by setting `doAlert` to `false`

⚠️ `ytdlp {`
- 📋 Alert tooltip on completion can now be silenced by setting `doAlert` to `false`

📍 `download()`
- ✅ Fixed function incorrectly naming some files causing subsequent functionality to fail
- ✅ Fixed function sometimes failing to index correctly causing duplicate downloads to cancel
- 📋 Will attempt to select the downloaded file in the `explorer` window if `openDirOnFinish` is set to `true`

⚠️ `prem {`
- ✅ Fixed `save()` using incorrect logic and incorrectly determining premiere as `busy`
- ✅ Fixed `rippleTrim()` tracking incorrectly
- ✏️ Added `toggleEnabled()`
- ✏️ Added `soloVideo()`
- ✏️ Added `swapPreviousSequence()`
- ✏️ Added `closeActiveSequence()`
- 📋 Moved `__setTimelineCol()` out of `Premiere_RightClick.ahk` and into `prem {`
- 📋 `toggleLayerButtons()` will now wait for some activation hotkeys to be released before continuing
- 📋 `changeLabel()` will no longer focus the timeline if the `Projects` window is the active panel so that the user may still assign labels to sequences
- 📋 `block_ext {` now allows <kbd>Escape</kbd> by default so that <kbd>Ctrl + Shift + Escape</kbd> is accessible even while inputs are blocked
- 📋 Theme selection is now determined automatically (for Premiere versions greater than `v25.0`) using the user's Premiere settings file, or through `settingsGUI()` for versions before `v25.0`
    - ❗ `rbuttonPrem().movePlayhead` no longer requires the user's theme to be passed in as a parameter
> [!Warning]
> Keep in mind only the `darkest` theme has its colours set currently & basically all `ImageSearch` screenshots across the repo are taken in the `darkest` theme (and with `Accessible Colour Contrast` disabled).  
> If you use an alternative theme, please update `Premiere_TimelineColours.ahk`, and take fresh screenshots, then consider submitting a pull request!

📍 `numpadGain()`
- 📋 Will now exit early if no clip is selected instead of needing to timeout
- ❗ `PremiereRemote` is now required

📍 `delayPlayback()`
- ✅ Fixed function not delaying the <kbd>Space</kbd> input at all
- ✅ Fixed function unnecessarily delaying the <kbd>Space</kbd> input if the user's PriorKey was a ripple trim, but more than the delay time has passed

`disableAllMuteSolo()`
- ✅ Fixed function sometimes activating some `Mute` icons
- 📋 Will now wait for some activation hotkeys to be released before continuing

⚠️ `Startup {`
- ✅ Fixed `updatePackages()` using incorrect string for newer versions of `chocolatey` causing the update process to fail
- 📋 `gitBranchCheck()` will no longer continue if changes are waiting to be `pushed` to avoid issues
- 📋 `adobeVerOverride()` will now show the user's selected Premiere `theme` during its selected version `Notify {`

📍 `HotkeylessAHK.ahk`
- 📋 Can now be rebooted from `trayMen()`
- 📋 The user will be alerted about whether script is open/closed on script reboot

## Other Changes
- ✏️ Added `PremiereRemote` function `toggleEnabled()` & `closeActiveSequence()`
- ❌ Removed `audPart.ahk`, `audSelect.ahk`, `projAudio.ahk`, `projVideo.ahk`, `sfx.ahk`, `thumbnail.ahk`, `vfx.ahk`, `video.ahk`, `vidPart.ahk`, and `vidSelect.ahk` as `mult-dl.ahk` encapsulates all of them

📍 `mult-dl.ahk`
- ✏️ Can now download thumbnails
- 📋 Will default its `FileSelect` to an active `Explorer` window if one is present
- 📋 Will now properly limit the `Part` tabs `UpDwn` inputs to 2 values and only numbers
- 📋 Will attempt to select the downloaded file in the `explorer` window

📍 `generateProxies.ahk`
- ✅ Fixed script failing to generate some metadata causing it to outright fail
- ✅ Fixed script attempting to operate on non video files
- ✅ Fixed script failing to recurse correctly
- 📋 Will default its `FileSelect` to an active `Explorer` window if one is present