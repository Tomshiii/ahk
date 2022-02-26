# <> Release 2.3.1.4

## > Functions
- `valuehold()` will no longer work with "any" value panel length and is now hard coded. Allowing it to work across a broader length made it unreliable and more likely to grab the incorrect value. While I do try to make as many functions as possible as flexible as possible, when it comes to this specific function, accuracy is far more important
    - Testing a loop to check multiple times for the desired value

## > My Scripts
- `Alt & p` macro has been updated to work with a newer win11 update (21H2)
- `SC03A & v` macro given more logic as it would constantly fail on first use

## > Other Changes
- `autosave.ahk` changed to function off of a timer instead of sleeps
- Minor changes to `autodismiss error.ahk` & `premiere_fullscreen_check.ahk` so they aren't constantly spam waiting for their respective windows