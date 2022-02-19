# <> Release 2.3.1.3 - Hotfix

###### **_Please note: in this changelog I will be linking to commits, these commits might not be the latest version of said code as things are changing all the time and adding dates would get incredibly confusing, don't copy/paste from these linked commits, check out the current version of the code in the script files themselves._**

## > My Scripts
- `updateChecker()` now [removes all urls](https://bit.ly/3gZ3il4) from the generated changelog instead of just bit.ly links

## > Streamdeck AHK
- Added [functions to pause](https://bit.ly/3h0sx6o) both the `autosave.ahk` & `premiere_fullscreen_check.ahk` scripts so they don't try to fire during other scripts
- Stream [start/end scripts close/open both](https://bit.ly/3oVe0gT) `autosave.ahk` & `premiere_fullscreen_check.ahk` respectively

## > Other Changes
- `premiere_fullscreen_check.ahk`
    - Will no longer try to fire on panels/windows that aren't the [main Premiere window](https://bit.ly/3JFhhIW)
    - Checks to make sure the user is [idle on the keyboard](https://bit.ly/3pmiJZl) for 2s before firing
    - Fixed a mistake causing it to only add 1s to the timer instead of 10s
    - Made the frequency the script fires a [user adjustable variable](https://bit.ly/3LDLeei) for convenience