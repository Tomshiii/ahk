# <> Release 2.15.x - 

## Functions
- ✅ Fixed `KeyShortAdjust {` throwing if script is called but the `.ini` file doesn't exist
- ✅ Fixed `settingsGUI()` throwing if the user attempts to <kbd>Open > Wiki Dir</kbd> and the directory does not exist
- ✏️ Added `block_ext {` a block class that allows complete input blocking without the script being run as admin

⚠️ `prem {`
- ✅ Fixed `dragSourceMon()` throwing if unable to determine the active window due to prem being busy
- `numpadGain()`
    - ✅ Fixed function arbitrarily being unable to make adjustments larger than 15db
        - *note: prem still has an internal limit of +15db for the `levels` property*
    - Function can now adjust the `levels` property in `float` instead of only `int`
        - Will require the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as `index.tsx` has been adjusted
    - Will clean up the input keys using `regex` instead of outright failing if any other key is pressed accidentally

⚠️ `premUIA_Values {`
- `__setNewVal()`
    - ✅ Fixed function failing if an error window appears during the process
        - Should now use `prem.dismissWarning()` to first remove the error message before continuing
    - ✅ Fixed function trying to set UIA values multiple times if function is called again shortly after it starts running

⚠️ `discord {`
- ❗All functions are now completely `ImageSearch` free. Meaning discord updates should no longer constantly break these functions!
- 📋 `Unread()` will now use `PixelSearch` & `UIA` to find; unread `servers`/`channels` & the `Mark as Read` button instead of relying on screenshots
> [!caution]
> Parameter `which` now requires either `channels` or `servers`
- `button()`
    - 📋 Function now uses `UIA` to click the desired buttons instead of relying on screenshots.
    - ✅ Fixed function attempting to fire while the user is not hovering the window
> [!caution]
> Parameter `button` now requires; `reply`, `edit`, `react`, `delete` or `report`

`slack {`
- `button()`
    - 📋 Function now uses `UIA` to click the desired buttons instead of relying on screenshots.
        - `reply` is now additionally supported
    - ✅ Fixed function attempting to fire while the user is not hovering the window

## Other Changes
- `backupProj.ahk` will now only ask if you wish to backup additional video folders *if* there are folders other than `footage` present

⚠️ `mult-dl.ahk`
- ❗Now offers `Single`, `Multi` & `Part` downloading options
- ✅ Fixed a function using incorrect logic causing the user to be unable to install `yt-dlp`/`ffmpeg`
- ✅ Fixed user being able to bypass installation steps by simply closing the window
- ✅ Fixed compiled script throwing after installation
- ✅ Fixed script sometimes downloading `vp9` codec videos when `avoid reencode` is enabled
- ✅ Fixed script attempting downloads using the user's clipboard if the user attempts to press either of the download buttons without inputting any URLs
- Compiled executable will now append the new version number to the update `.exe` download to prevent the user from trying to download to the same directory and having nothing happen as `Download` would silently fail
- Main window will now be disabled during update check
- No longer *requires* `chocolatey` to be installed to use script, only during any installation processes
- Will now perform an automatic package update check on startup for `ffmpeg` && `yt-dlp`
- `Check for updates` button will only prompt the user for admin if there are actual updates available. Otherwise it will inform the user there are none
    - Button will also dynamically update to communicate to the user that an update check is being performed