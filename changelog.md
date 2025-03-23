# <> Release 2.15.x - 

## Functions
- ✅ Fixed `KeyShortAdjust {` throwing if script is called but the `.ini` file doesn't exist

## Other Changes

⚠️ `mult-dl.ahk`
- Fixed function using incorrect logic causing the user to be unable to install `yt-dlp`/`ffmpeg`
- Fixed user being able to bypass installation by simply closing the window
- Fixed compiled script throwing after installation
- Fixed script sometimes downloading `vp9` codec videos when `avoid reencode` is enabled
- Main window will now be disabled during update check