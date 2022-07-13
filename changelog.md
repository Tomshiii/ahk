# <> Release 2.4.1.x

# > Functions
- `manInput()` now grabs the activation hotkeys and does string manipulation to get its parameters instead of needing to manually pass them into the function.
    - Added `getSecondHotkey()` for this to work
    - Moved `keyend` to a `KSA` value instead to remove another variable that would otherwise need to be passed to the function
- Moved the `Keywait()` in `gain()` so that holding the key wasn't queuing up the function
- `mouseDrag()` now checks the users mouse coords and ensures it does not fire when the user is outside the bounds of the timeline
- `zoom()` now has preset values for certain clients

# > checklist
- Can now add or remove a custom amount of minutes between `1-10min`
- Will now additionally log the `frame count` at every stage

# > KSA
- Removed `levelsHotkey`, `replyHotkey` & `textHotkey` and instead have the respective function check if the variable passed into it is the secondary version of the function. (`preset()`, `valuehold()` & `disc()` are affected by this change)

# > Other Changes
- Rearranged `QMK Keyboard.ahk`
- Added a diagram to `readme.md` to visual show what `autosave.ahk` does

`right click premiere.ahk`
- Fixed a bug that would stop the script from firing if the user had just let go of the `Rbutton`, not moved the mouse at all, then tried to reactivate the script
- If the cursor is within close proximity to the playhead, it will now warp to it and hold down `Lbutton` to drag around the playhead instead of using the other method. Moving the playhead in this manor is slightly more performant