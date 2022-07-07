# <> Release 2.4.1.x

# > Functions
- `manInput()` now grabs the activation hotkeys and does string manipulation to get its parameters instead of needing to manually pass them into the function.
    - Added `getSecondHotkey()` for this to work
    - Moved `keyend` to a `KSA` value instead to remove another variable that would otherwise need to be passed to the function
- Moved the `Keywait()` in `gain()` so that holding the key wasn't queuing up the function
- `mouseDrag()` now checks the users `x` mouse coord and ensures it does not fire when the user is beyond/before the bounds of the timeline

# > KSA
- Removed `levelsHotkey`, `replyHotkey` & `textHotkey` and instead have the respective function check if the variable passed into it is the secondary version of the function. (`preset()`, `valuehold()` & `disc()` are affected by this change)

# > Other Changes
- Rearranged `QMK Keyboard.ahk`