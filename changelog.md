# <> Release 2.16.x - 
> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replaceAndReset.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `keys.allWait()` stopping a hotkey too early
- ✅ Fixed `getHotkeys()` incorrectly returning boolean `false` in some circumstances
- ✅ Fixed `ffmpeg.isVideo()` throwing if the file does not exist
- 📋 `premUIA_Values {` will now check for stuck keys after completion 
- 📋 `ytdlp().download()` now accepts parameter `cookies`

⚠️ `getHotkeysArr()`
- ✅ Fixed function returning <kbd><!</kbd> as `<` & `!` instead of as one hotkey
- ✅ Fixed function being case sensitive when it shouldn't have been
- 📋 Will now return all hotkeys as `vk` values instead of a mix of `vk` and regular strings

⚠️ `prem {`
- ✅ Fixed `save()` not properly determining if `Premiere` may be busy
- ✅ Fixed `gain()` attempting to continue even if a clip is not selected
- ✅ Fixed failed attempts to create a UIA object causing the script to throw
- ✏️ Added `changeDupeFrameMarkers()`
- ✏️ Added `isEditTabActive()`
- 📋 Renamed `__checkTimeline()` => `__setTimelineValues()`
- 📋 Renamed `__checkTimelineFocus()` => `__focusTimeline()`

📍 `changeLabel()`
- ✅ Fixed function throwing if activated with `HotkeylessAHK` while `Premiere` was not the active window
- ✅ Fixed function sending hotkeys even if a clip was not selected

📍 `toggleEnabled()`
- ✅ Fixed function sometimes not deselecting clips
- ✏️ Now accepts parameter `allExcept` to toggle all tracks *except* the desired track *or* all tracks beyond the `offset` value
- 📋 Can now instantly change multiple tracks if the user places the activation hotkeys correctly. (see the [wiki for more info](<https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#premtoggleenabled>))
- 📋 Will now move the playhead out of the way if the cursor is hovering over it
- 📋 Will now check the initial state of the selection and reattempt a failed toggle
- 📋 Will now use `PremiereRemote` to determine the max clip length to check for
> [!Caution]
> This function requires updated `PremiereRemote` functions.

## Other Changes
- ✅ Fixed `backupProj.ahk` operating on the incorrect folder if; a Premiere project is open, but another project is selected
- ✅ Fixed `zip prem proj.ahk` not copying extra directories the user agrees to copying
- ✏️ Added `replaceAndReset.ahk` `PremiereRemote` script
- ✏️ Added `HighPrecisionSleep` by [thqby](<https://github.com/thqby/ahk2_lib/blob/master/HighPrecisionSleep.ahk>)
- ✏️ Added `ShinsImageScanClass` by [Spawnova](<https://github.com/Spawnova/ShinsImageScanClass/blob/main/AHK%20V2/ShinsImageScanClass.ahk>)

⚠️ `mult-dl.ahk`
- ✅ Fixed script throwing while attempting to download thumbnails
- ✏️ Added new icon
- 📋 Downloads will now simply default to `..\Downloads\tomshi`
- 📋 Use of cookies can now be toggled

⚠️ `autosave.ahk`
- ✅ Fixed `__savePrem()` not properly determining when `Premiere` may be busy
- ✅ Fixed `__saveAE()` causing an idle check even if a save wasn't required
- 📋 `__reactivateWindow()` will no longer reactivate `Premiere` if it was the original window but `PremiereRemote` was used to save
- 📋 Will now show visually when the next save attempt will occur
- 📋 Will now check if `Premiere` is on the edit tab and cancel the save attempt if it isn't

⚠️ `PremiereRemote`
- ✏️ Added `isClipEnabled()`
- ✏️ Added `movePlayheadFrames()`
- ✏️ Added `getAudioTracks()`/`getVideoTracks()`