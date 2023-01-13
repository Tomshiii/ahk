# <> Release 2.9.x - 
- `generateUpdate.ahk` will now delete a number of files/dirs that aren't necessary to contain within release files, this helps save on final filesize
- Changed all methods in classes that are intended to be `"private"` to start with `__`
    - eg. `__inputs()`

## > Functions
- Added `allKeyWait()` a wrapper function that handles different methods of activating hotkeys/functions
    - Replaced as many instances of simply using `KeyWait` as possible to make functions less error prone in the event a user calls them in a different way to myself
- Fixed `startup.libUpdateCheck()` comparing versions incorrectly
- Moved `isReload()` out of `startup {` and into its own function
- `allKeyUp()` will now send `Esc` after every `Key Up` event to try and mitigate damage from sending so many keystrokes

`tool.Cust()`
- Fixed not properly returning the original `CoordMode`
    - Fixes `right click resolve` macro not working correctly on first use but being fine after
- Will now check all passed parameters to ensure the correct types are used

## > Other Changes
- Added `thqby's` `print.ahk` & `JSON.ahk` lib files to help with debugging

`Listlines` & `KeyHistory`
- Scripts that do not need to log keys/lines have had them disabled

###### > The following will no longer log lines so that they don't flood the log
- `tool.Cust()`
- `On_WM_MOUSEMOVE.ahk`
- Moved the `while` loop out of `right click premiere.ahk` => `premKeyCheck.ahk`