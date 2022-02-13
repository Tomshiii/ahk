# <> Release 2.3.1.3

###### **_Please note: in this changelog I will be linking to commits, these commits might not be the latest version of said code as things are changing all the time and adding dates would get incredibly confusing, don't copy/paste from these linked commits, check out the current version of the code in the script files themselves._**

## > My Scripts
- `updateChecker()` now removes all urls from the generated changelog instead of just bit.ly links

## > Streamdeck AHK
- Added functions to pause both the `autosave.ahk` & `premiere_fullscreen_check.ahk` scripts so they don't try to fire during other scripts

## > Other Changes
- `premiere_fullscreen_check.ahk` will no longer try to fire on windows disconnected from the main premiere window
    - Fixed a mistake causing it to only add 1s to the timer instead of 10s
    - Made the frequency the script checks a user adjustable variable for convenience