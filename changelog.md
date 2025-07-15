# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `ytdlp.download()` incorrectly naming some files causing subsequent functionality to fail
- ✅ `getHotkeys()` will now handle hotkeys similar to <kbd><!2</kbd>
- 📋 Moved `timelineColours {` out of `Premiere_RightClick.ahk` and into its own file
- ✏️ Added `ffmpeg().isVideo()`

`prem {`
- 📋 Theme selection is now determined automatically (for Premiere versions greater than `v25.0`) using the user's Premiere settings file, or through `settingsGUI()` for versions before `v25.0`
    - ❗ `rbuttonPrem().movePlayhead` no longer requires the user's theme to be passed in as a parameter
> [!Warning]
> Keep in mind only the `darkest` theme has its colours set currently & basically all `ImageSearch` screenshots across the repo are taken in the `darkest` theme (and with `Accessible Colour Contrast` disabled). If you use an alternative theme, please update `Premiere_TimelineColours.ahk`, and take fresh screenshots, then consider submitting a pull request!
- ✅ Fixed `save()` using incorrect logic and incorrectly determining premiere as `busy`
- ✅ Fixed `rippleTrim()` tracking incorrectly
- ✏️ Added `toggleEnabled()`
- 📋 Moved `__setTimelineCol()` out of `Premiere_RightClick.ahk` and into `prem {`
- 📋 `toggleLayerButtons()` & `disableAllMuteSolo()` will now wait for some activation hotkeys to be released before continuing
- 📋 `changeLabel()` will no longer focus the timeline if the `Projects` window is the active panel so that the user may still assign labels to sequences

📍 `delayPlayback()`
- ✅ Fixed function not delaying the <kbd>Space</kbd> input at all
- ✅ Fixed function unnecessarily delaying the <kbd>Space</kbd> input if the user's PriorKey was a ripple trim, but more than the delay time has passed

⚠️ `Startup {`
- 📋 `gitBranchCheck()` will no longer continue if changes are waiting to be `pushed` to avoid issues
- 📋 `adobeVerOverride()` will now show the user's selected Premiere `theme` during its selected version `Notify {`

📍 `HotkeylessAHK.ahk`
- 📋 Can now be rebooted from `trayMen()`
- 📋 The user will be alerted about whether script is open/closed on script reboot

## Other Changes
- ✏️ Added `PremiereRemote` function `toggleEnabled()`
- ❌ Removed `audPart.ahk`, `audSelect.ahk`, `projAudio.ahk`, `projVideo.ahk`, `sfx.ahk`, `thumbnail.ahk`, `vfx.ahk`, `video.ahk`, `vidPart.ahk`, and `vidSelect.ahk` as `mult-dl.ahk` encapsulates all of them

📍 `mult-dl.ahk`
- 📋 Will default its `FileSelect` to an active `Explorer` window if one is present
- 📋 Will now properly limit the `Part` tabs `UpDwn` inputs to 2 values and only numbers
- ✏️ Can now download thumbnails

📍 `generateProxies.ahk`
- ✏️ Will default its `FileSelect` to an active `Explorer` window if one is present
- ✅ Fixed script failing to generate some metadata causing it to outright fail
- ✅ Fixed script attempting to operate on non video files