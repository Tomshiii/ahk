# <> Release 2.3.2 - Error Log

This release brings along the function `errorLog()` that can be used to log instances of a script failing to do what it was supposed to do and append it into a generated `\Error Logs\*.txt` directory/file. Files are sorted by `YYYY_MM_DD_ErrorLog.txt`.

Eg.
```
18:05:10.403 // valueHold() encountered the following error: The user wasn't scrolled down
```
# ◇ Further Changelog

## > Functions
- `valuehold()` will no longer work with "any" value panel length and is now hard coded. Allowing it to work across a broader length made it unreliable and more likely to grab the incorrect value. While I do try to make as many functions as possible as flexible as possible, when it comes to this specific function, accuracy is far more important
    - *Currently testing a loop to search multiple times for the desired value in an attempt to minimise failed attempts*
    - Moved some code into a `try{}` `catch{}` combo in an attempt to catch an edge case error
- `disc()` now loops trying to find the desired button instead of waiting a set `500ms` on initial failure
    - Also loops to try and find the `@ reply ping` button
    - Now has logic to tell if it's in a dm or not so the tooltip about the `@ reply ping` won't fire in a dm
- Moved the remaining functions from `Functions.ahk` to the new `General.ahk` so that I can `#Include` it in all the other function files to make creating and editing functions easier within VSCode

## > My Scripts
- `Alt & p` macro has been updated to function on a newer win11 update (21H2)
- `SC03A & v` macro given more logic as it would constantly fail on first use

## > Other Changes
- `autosave.ahk` changed to function off of a timer instead of sleeps
    - Moved ability to pause `autosave.ahk` back into its own script
- Minor changes to `autodismiss error.ahk` & `premiere_fullscreen_check.ahk` so they aren't constantly spam waiting for their respective windows
- Removed as many hard coded references to `C:\Program Files\ahk\ahk` which is the dir that ***I*** (use to) have these scripts. After this update all you should need to do is change the `location` variable in `KSA.ahk`  & `SD_functions.ahk` and most scripts should function as intended. (*some `Streamdeck AHK` scripts still have hard coded dir's*)
- Changed a few `DirSelect` to `FileSelect` with the folder option enabled as they're easier/quicker to navigate