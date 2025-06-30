# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `ytdlp.download()` incorrectly naming some files causing subsequent functionality to fail
- ✅ `getHotkeys()` will now handle hotkeys similar to <kbd><!2</kbd>
- 📋 Moved `timelineColours {` out of `Premiere_RightClick.ahk` and into its own file

`prem {`
- ✏️ Added `toggleEnabled()`
- 📋 Moved `__setTimelineCol()` out of `Premiere_RightClick.ahk` and into `prem {`
- 📋 `toggleLayerButtons()` & `disableAllMuteSolo()` will now wait for shome activation hotkeys to be released before continuing

⚠️ `Startup {`
- 📋 `HotkeylessAHK.ahk` can now be rebooted from `trayMen()`
- 📋 `gitBranchCheck()` will no longer continue if changes are waiting to be `pushed` to avoid issues

## Other Changes
- ✅ Fixed `generateProxies.ahk` failing to generate some metadata causing it to outright fail
- ✏️ Added `PremiereRemote` function `toggleEnabled()`