# <> Release 2.15.x - 

## Functions
- ✅ Fixed `KeyShortAdjust {` throwing if script is called but the `.ini` file doesn't exist
- ✅ Fixed `slack.button()` attempting to fire while the user is not hovering the window
- ✅ Fixed `settingsGUI()` throwing if the user attempts to <kbd>Open > Wiki Dir</kbd> and the directory does not exist
- ✏️ Added `block_ext {` a block class that allows complete input blocking without the script being run as admin

⚠️ `prem {`
- ✅ Fixed `dragSourceMon()` throwing if unable to determine the active window due to prem being busy
- ✅ Fixed `numpadGain()` arbitrarily being unable to make adjustments larger than 15db
    - *note: prem still has an internal limit of +15db for the `levels` property*

⚠️ `premUIA_Values {`
- `__setNewVal()`
    - ✅ Fixed function failing if an error window appears during the process
        - Should now use `prem.dismissWarning()` to first remove the error message before continuing
    - ✅ Fixed function trying to set UIA values multiple times if function is called again shortly after it starts running

⚠️ `discord {`
- 📋 Replaced screenshots for new theme (I personally use `onyx`, `compact` at <kbd>70% saturation</kbd>. If you use anything else you'll be required to take all new screenshots and adjust a little code within the class unless you simply override the onyx screenshots)
- `button()`
    - ✅ Fixed function failing to find the requested button if the right click context menu opens to the left of the cursor
    - ✅ Fixed function attempting to fire while the user is not hovering the window

## Other Changes
- `backupProj.ahk` will now only ask if you wish to backup additional video folders *if* there are folders other than `footage` present

⚠️ `mult-dl.ahk`
- Fixed a function using incorrect logic causing the user to be unable to install `yt-dlp`/`ffmpeg`
- Fixed user being able to bypass installation steps by simply closing the window
- Fixed compiled script throwing after installation
- Fixed script sometimes downloading `vp9` codec videos when `avoid reencode` is enabled
- Compiled executable will now append the new version number to the update `.exe` download to prevent the user from trying to download to the same directory and having nothing happen as `Download` would silently fail
- Main window will now be disabled during update check
- No longer *requires* `chocolatey` to be installed to use script, only during any installation processes
- Will now perform an automatic package update check on startup for `ffmpeg` && `yt-dlp`
- `Check for updates` button will only prompt the user for admin if there are actual updates available. Otherwise it will inform the user there are none
    - Button will also dynamically update to communicate to the user that an update check is being performed