# <> Release 2.15.x - 

## Functions
- ✅ Fixed `KeyShortAdjust {` throwing if script is called but the `.ini` file doesn't exist
- ✅ Fixed `premUIA_Values.__setNewVal()` failing if an error window appears during the process
    - Should now use `prem.dismissWarning()` to first remove the error message before continuing

## Other Changes

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