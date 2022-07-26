# <> Release 2.4.2.x -
- Changed all leftover uses of redundant `else if`'s to proper uses of `||` (Mostly a lot of `ImageSearch`'s that were stacked below each other)

# > Other Changes

`replaceChecklist.ahk`
- Now checks the user's in use version of `checklist.ahk`, compares it to the version in the main script directory and only replaces it if the main version is newer
- Will now prompt the user to select their desired search folder if it doesn't exist and will then permanently overwrite its value

`checklist.ahk`
- Can now manually input minutes to +/- in addition to the preset 10
- `Hours:` number will no longer visually cut off the bottom of the `Time Adjust` group box
- Logs will now group by day to increase readability
    - Replaced all wording of `frames` and replaced with `seconds`. Video editor brain let that one slip through the cracks for a bit too long
- Script version can now be seen in the top right corner
- Less elements have baked in `x/y values` and instead sit relative to their previous elements
- Minor UI adjustments