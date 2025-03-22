# <> Release 2.15.4 - `yt-dlp.ahk` Hotfix
Although this release comes hot off the heels of <kbd>v2.15.3</kbd> I wanted to semi-rush this one out to fix a few mishaps with `yt-dlp.ahk`.

## Functions
- ✅ Fixed `getLocalVer()` returning early

⚠️ `ytdlp {`
- `download()`
    - Fixed function failing if `URL` param isn't passed into the function
    - Fixed function sometimes failing to increment the filename if a video is downloaded multiple times
    - Function will now manually check the codec of the downloaded file, if it isn't `h264` or `h265` it will use an additional command to reencode the downloaded file
        - While previously it more or less already did this, this method will now spawn a new cmdline window which will in turn give the user the live progress of the encode
    - Now accepts parameter `openDirOnFinish` to determine whether to open the destination directory once completed
    - Now accepts parameter `postArgs` to execute cmdline commands after the initial download is complete
        - *Please note:* if a custom arg string is passed to `postArgs` the function will **no longer** do its check to determine if the downloaded file is `h264` or `h265`. The user's custom arg will run regardless.

## Other Changes
- ✏️ Added `delete0kb.ahk`
- ✏️ Added `mult-dl.ahk`