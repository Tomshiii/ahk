# <> Release 2.4.2.x -
- Changed all leftover uses of redundend `else if`'s to proper uses of `||` (Mostly a lot of `ImageSearch`'s that were stacked below each other)

# > Other Changes
- `replaceChecklist.ahk` now compares the user's in use version of `checklist.ahk`, compares it to the version in the main script directory and only replaces it if the main version is newer

`checklist.ahk`
- Can now manually input minutes to +/- in `checklist.ahk` in addition to the preset 10
- `Hours:` number will no longer cut off the bottom of the `Time Adjust` group box
- Minor UI adjustments