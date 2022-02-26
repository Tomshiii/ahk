# <> Release 2.3.2 - Error Log

This release brings along the function `errorLog()` that will log all instances of a script failing to do what it was supposed to do and log it in a generated `\Error Logs` directory in files sorted by `YYYY_MM_DD_ErrorLog.txt`.

Eg.
```
18:05:10.403 // valueHold() encountered the following error: The user wasn't scrolled down
```
# > Further Changelog

## > Functions
- `valuehold()` will no longer work with "any" value panel length and is now hard coded. Allowing it to work across a broader length made it unreliable and more likely to grab the incorrect value. While I do try to make as many functions as possible as flexible as possible, when it comes to this specific function, accuracy is far more important
    - *Currently testing a loop to search multiple times for the desired value in an attempt to minimise failed attempts*
- `disc()` now loops trying to find the desired button instead of waiting a set `500ms` on initial failure
    - Also loops to try and find the `@ reply ping` button
    - Now has logic to tell if it's in a dm or not so the tooltip about the `@ reply ping` won't fire in a dm

## > My Scripts
- `Alt & p` macro has been updated to work with a newer win11 update (21H2)
- `SC03A & v` macro given more logic as it would constantly fail on first use

## > Other Changes
- `autosave.ahk` changed to function off of a timer instead of sleeps
- Minor changes to `autodismiss error.ahk` & `premiere_fullscreen_check.ahk` so they aren't constantly spam waiting for their respective windows