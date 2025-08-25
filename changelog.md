# <> Release 2.16.x - 
> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replaceAndReset.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `keys.allWait()` stopping a hotkey too early
- ✅ Fixed `getHotkeys()` incorrectly returning boolean `false` in some circumstances
- 📋 `premUIA_Values {` will now check for stuck keys after completion 
- 📋 `ytdlp().download()` now accepts parameter `cookies`

⚠️ `getHotkeysArr()`
- ✅ Fixed function returning <kbd><!</kbd> as `<` & `!` instead of as one hotkey
- ✅ Fixed function being case sensitive when it shouldn't have been
- 📋 Will now return all hotkeys as `vk` values instead of a mix of `vk` and regular strings

⚠️ `prem {`
- ✅ Fixed `save()` not properly determining if `Premiere` may be busy
- ✅ Fixed `gain()` attempting to continue even if a clip is not selected
- ✏️ Added `changeDupeFrameMarkers()`

📍 `changeLabel()`
- ✅ Fixed function throwing if activated with `HotkeylessAHK` while `Premiere` was not the active window
- ✅ Fixed function sending hotkeys even if a clip was not selected

📍 `toggleEnabled()`
- ✅ Fixed function sometimes not deselecting clips
- ✏️ Now accepts parameter `allExcept` to toggle all tracks *except* the desired track *or* all tracks beyond the `offset` value
- 📋 Can now instantly change multiple tracks if the user places the activation hotkeys correctly. (see the [wiki for more info](<https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#premtoggleenabled>))
- 📋 Will now check the initial state of the selection and reattempt any failed toggles
> [!Caution]
> This function requires updated `PremiereRemote` functions.

## Other Changes
- ✅ Fixed `backupProj.ahk` operating on the incorrect folder if a Premiere project is open, but another project is selected
- ✅ Fixed `zip prem proj.ahk` not copying extra directories the user agrees to copying
- ✏️ Added `replaceAndReset.ahk` `PremiereRemote` script

⚠️ `mult-dl.ahk`
- ✏️ Added new icon
- 📋 Downloads will now simply default to `..\Downloads\tomshi`
- 📋 Use of cookies can now be toggled

⚠️ `autosave.ahk`
- ✅ Fixed `__savePrem()` not properly determining when `Premiere` may be busy
- 📋 `__reactivateWindow()` will no longer reactivate `Premiere` if it was the original window but `PremiereRemote` was used to save
- 📋 Will now show visually when the next save attempt will occur