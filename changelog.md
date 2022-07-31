# <> Release 2.4.3 -
This release is centered around fixing old sloppy practices that have just been left in the code because, *"if it aint broke, don't fix it"*
- Changed all leftover uses of redundant `else if`'s to proper uses of `||` (Mostly a lot of `ImageSearch`'s that were stacked below each other). This helps cleanup repeated code blocks as well as making instances with more than 2 `||`'s more easily readable
- Removed all instances of `%&variableX%` and replaced with `variableX` as the additional syntaxing isn't neccesary for what my scripts do

# > My Scripts
- Added `^+t::` to type out `YYYY-MM-DD`
- All instances of `ClipWait` now have code to fallback on if no data is ever fed to the clipboard.
- Moved discord `F1:: & F2::` code to `discUnread()` to cut repeat code
- Added `A_MaxHotkeysPerInterval := 400` so spamming my unclicked scroll wheel stops creating an error

# > Functions
- `updateChecker()` now shows `TrayTip`'s to alert the user that it's downloading the latest release & backing up their scripts
- Replaced `getSecondHotkey()` with `getHotkeys()` to grab both the first and second hotkeys when two are required for activation
- Added `moveXorY()` to easily move the mouse along one axis. This method isn't anything special but useful when you need a quick and dirty way to move along one axis
- `zoom()` will toggle between two options when working on an `Alex` project
- `reset()` will no longer reset the track colour
- Removed use of `getClassNN()`. If it failed to grab `classNN` values it would simply pass back unset variables and cause errors
- `getMouseMonitor()` will now only loop as many times as you have monitors
- `audioDrag()` will now check `A_PriorKey` and if it's a digit, assign that to the track number you wish to move the `bleep` sfx to, instead of checking the state of each individual digit

`isFullscreen()`
- Fixed bug that could cause windows to go full [windows xp lagscreen](https://tinyurl.com/23vobypv)
- Can now have the window you wish to check passed into the function instead of relying on `getTitle()` to grab the active window

`moveTab()`
- Fixed function not working on `monitor 4`
- Will now work even if firefox wasn't already the active window
- Will now check the tab for fullscreen instead of the active window
- Now has more sophisticated code to try and ensure it only grabs a tab
- No longer requires the user to `LButton` to finish the function as it will check for 2s if the user has released the `RButton`

# > checklist.ahk
- Can now manually input minutes to +/- in addition to the preset 10
- `Hours:` number will no longer visually cut off the bottom of the `Time Adjust` group box
- Script version can now be seen in the top right corner
- Less elements have baked in `x/y` values and instead sit relative to their previous elements
- `Title` will no longer create a new line if it's too long
- Minor UI adjustments
- `Logs`
    - Replaced wording of opposite logs to be more similar and reduce visual confusion
    - Will now group by day to increase readability
        - Will show the hours you started at for each day at the top of the group
    - Replaced all wording of `frames` and replaced with `seconds`. Video editor brain let that one slip through the cracks for a bit too long
    - Replaced wording `application` with `checklist`
    - Fixed the `-sub` & `+add` buttons both using the word `removed` in the logs

`replaceChecklist.ahk`
- Now checks the user's in use version of `checklist.ahk`, compares it to the version in the main script directory and only replaces it if the main version is newer
- Will now prompt the user to select their desired search folder if it doesn't exist and will then permanently overwrite its value

# > Other Changes
- Changed all instances of `errorLog()` initiated via a hotkey to output : `A_Hotkey "::"` instead of just `A_Hotkey`

`right click premiere.ahk`
- Will now stop playback before attempting to warp to the playhead if it is close to the cursor. This is to prevent the mouse from missing the playhead while trying to warp to it while playback is occuring
- Will now always attempt to swap back to the selection tool incase the user has another tool selected