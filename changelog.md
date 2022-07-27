# <> Release 2.4.2.x -
This release is centered around fixing old sloppy practices that have just been left in the code because `if it aint broke, don't fix it`
- Changed all leftover uses of redundant `else if`'s to proper uses of `||` (Mostly a lot of `ImageSearch`'s that were stacked below each other)
- Removed all instances of `%&variableX%` and replaced with `variableX` as the additional syntaxing isn't neccesary

# > My Scripts
- Added `^+t::` to type out `YYYY_MM_DD`
- All instances of `ClipWait` now have code to fallback on if no data is ever fed to the clipboard
- Moved discord `F1:: & F2::` code to `discUnread()` to cut repeat code

# > Functions
- Fixed bug with `isFullscreen()` that could cause windows to go full [windows xp lagscreen](https://tinyurl.com/23vobypv)

`moveTab()`
- Fixed function not working on `monitor 4`
- Will now work even if firefox wasn't already the active window

# > checklist.ahk
- Can now manually input minutes to +/- in addition to the preset 10
- `Hours:` number will no longer visually cut off the bottom of the `Time Adjust` group box
    - Replaced wording of opposite logs to be more similar and reduce visual confusion
- Script version can now be seen in the top right corner
- Less elements have baked in `x/y` values and instead sit relative to their previous elements
- Minor UI adjustments
- `Logs`
    - Will now group by day to increase readability
        - Will show the hours you started at for each day at the top of the group
    - Replaced all wording of `frames` and replaced with `seconds`. Video editor brain let that one slip through the cracks for a bit too long
    - Replaced wording `application` with `checklist`

`replaceChecklist.ahk`
- Now checks the user's in use version of `checklist.ahk`, compares it to the version in the main script directory and only replaces it if the main version is newer
- Will now prompt the user to select their desired search folder if it doesn't exist and will then permanently overwrite its value

# > Other Changes
- `right click premiere.ahk` will now stop playback before attempting to warp to the playhead if it is close to the cursor. This is to prevent the event that the mouse will miss it while trying to warp to it while playback is occuring 