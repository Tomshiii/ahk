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
> Keep in mind only the "darkest" theme has its colours set currently. If you use an alternative theme, please update `Premiere_TimelineColours.ahk` and consider submitting a pull request!
- ✅ Fixed `save()` using incorrect logic and incorrectly determining premiere as `busy`
- ✏️ Added `toggleEnabled()`
- 📋 Moved `__setTimelineCol()` out of `Premiere_RightClick.ahk` and into `prem {`
- 📋 `toggleLayerButtons()` & `disableAllMuteSolo()` will now wait for some activation hotkeys to be released before continuing
- 📋 `changeLabel()` will no longer focus the timeline if the `Projects` window is the active panel so that the user may still assign labels to sequences

⚠️ `Startup {`
- 📋 `HotkeylessAHK.ahk` can now be rebooted from `trayMen()`
- 📋 `gitBranchCheck()` will no longer continue if changes are waiting to be `pushed` to avoid issues

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
- 📋 Will now skip non video files