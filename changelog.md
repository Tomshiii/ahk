# <> Release 2.14.x - 

## > Functions
- `startup.updateChecker()` now allows the user to select `Skip this version` during the update prompt to no longer recieve a GUI about that individual update

`Premiere_RightClick.ahk`
- Fixed script indefinitely holding onto the playhead if the user quickly tapped <kbd>RButton</kbd> while the cursor was close to it
- Revert addition of `MouseHook {` as it was causing additional issues