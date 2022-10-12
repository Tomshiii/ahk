# <> Release 2.6 - Dark Mode (sorta) + Two New Scripts + Structure Overhaul
This release brings along two new scripts; `gameCheck.ahk` & `Multi-Instance Close.ahk`

- `gameCheck.ahk` is a script that will automatically detect when a predetermined game is currently active and suspend `My Scripts.ahk`. This is important because `My Scripts.ahk` contains a bunch of macros that really don't play nice to games and cause a lot of basic functionality in them to break. This script will also detect when the game is no longer the active window and unsuspend `My Scripts.ahk`. Games may be periodically added to this script but feel welcome to add your own list!
- `Multi-Instance Close.ahk` is a script that will periodically check for duplicate instances of any autohotkey scripts and close one of them. Even if you use `#SingleInstance Force` reloading scripts can sometimes cause a second instance to slip open. This script will hopefully mitigate the odd behaviour that occurs when this happens by closing any duplicates.

Alongside those two scripts, this update brings along a dark theme to certain GUI elements. AHK is rather limited in what it can apply in a modern way but a global dark mode option can now be enabled in `settingsGUI()`

# > Other Big Changes
- Completely redesigned `checklist.ahk` to run from the root dir instead of copying it to the project location
- Moved the following scripts to `..\Timer Scripts`;
    - `adobe fullscreen check.ahk`
    - `Alt_menu_acceleration_DISABLER.ahk`
    - `autodismiss error.ahk`
    - `autosave.ahk`
    - `gameCheck.ahk`
    - `Multi-Instance Close.ahk`
- Fix all dynamic comments
    - Add markers to all dynamic comments to indicate what type of information needs to be passed for each parameter
- `..\` used in a lot of places now to go back a dir instead of needing hardcoded values
- Added `..\lib\` to reduce the clutter of the root dir
    - Moved the `Functions` & `KSA` folder => `lib`
    - Moved all `checklist.ahk` functions to their own scripts within `\lib\checklist\` to increase readability
        - All functions are now labelled with dynamic comments to explain what they do
- `blockOn()/blockOff()`, `toolCust()/toolWait()` & `coords(), coordw(), coordc()` all changed to class instances =>
    - `block.On()/block.Off()`
    - `tool.Cust()/tool.Wait()`
        - Added `tool.Wait()` to cut repeat code. Makes your script wait for tooltips to finish before continuing
    - `coord.s()/coord.w()/coord.c()`

## > My Scripts
- Changed `F14::` `show more options` hotkey -> `F18` due to it causing issues with `F14 & WheelDown/WheelUp::`
- `F14 & WheelDown/WheelUp::` now calls `fastWheel()`
- Added the ability to toggle `CapsLock` by double tapping it
- Added `#+^r::` to hard refresh all open `.ahk` scripts (not including `checklist.ahk`)
    - Added `hardReset()` for this and so it can be used elsewhere
- `#+r::` will now create a list of open `.ahk` scripts and tell them to reload instead of requiring hard coded values
    - Will now produce a tooltip while reloading
- `SC03A & c::` now pastes the string instead of using a `Send{}` type to increase performance
- `getMonitor()` in `#c::` now returns a function object instead of a large list of variables
- `#c::` & `#f::` now ignore `checklist.ahk`

## > Functions
- Added `floorDecimal()` to round down after a determined amount of decimal places
- Added `blockOff()` to `getTitle()` and `isFullscreen()` so that in the event they fail, the user is not potentially stuck
- Added a check in `musicGUI()` to make sure to music folder actually exists
- Added `fastWheel()` to replace the simple `SendInput("{WheelDown/Up 10}")` and allow the function to focus the window under the cursor if it isn't currently the active window when called
- Added `detect()` to cut repeat code. Sets `DetectHiddenWindows` & `SetTitleMatchMode`
- Fixed hard coded dir in `switchToDisc()`
- Fixed some incorrect information in `hotkeysGUI()`
- `switchToAE()` now contains more elaborate code to be able to open the `.aep` file for the current Premiere project even once AE is already open
- `activeScripts()` now starts a timer to check the suspended state of `My Scripts.ahk` to update the checkbox value
- Condensed most `OnEvent`'s for `activeScripts()` to one singular function
- `moveXorY()` tooltips will no longer flicker
- `moveTab()` now makes sure the monitor objects have been set 
- Moved `getPremName()`, `getAEName()` & `getID()` => `Windows.ahk`
- `vscode()` now uses no `ImageSearch` and instead uses nothing but hotkeys

`audioDrag()`
- Added more colours
- Will now lower gain before cutting instead of after

`getMouseMonitor()`
- Now returns a function object and passes back all information
- Now `Exit`'s when `try{}` fails to stop potential runtime errors when called and a variable object hasn't been passed back

`tool.Cust()`
- Can now take custom `x` & `y` coordinates. They are unset by default and can be omitted
- Can now accept the `WhichToolTip` parameter from the actual `ToolTip` function
- Tooltip will now follow the cursor if no `x/y` coordinates have been passed to the function
    - Recreating the old way can be achieved with something along the lines of; `tool.Cust(message,,, MouseGetPos(&x, &y) x + 15, y)`
- Timeout variable can now accept `seconds` instead of only `ms` by using a non integer, ie; `2.5` or `0.5`

`zoom()`
- Now sets it's variable presets in an array to remove the need for multiple variables
- Now resets toggle values after 10 seconds

`settingsGUI()`
- Minor GUI tweaks
- Script names are now coloured to make it easier to read
- Fixed bug that caused function to error if non numeric values were entered into the edit boxes
- Now has an option to globally enable/disable reminder tooltips for `checklist.ahk`
- Moved `Current working dir:` to the status bar
    - Status bar now also shows whether `My Scripts.ahk` is active or suspended
- Ability to add game information to `gameCheck.ahk`

## > Other Changes
- Adjusted positioning of tray menu items for `My Scripts.ahk` & `autosave.ahk`
- Added `commLocation :=` to `Keyboard Shortcut Adjustments` for the user to manually input their own commission working dir (if they have one) so my scripts don't need to be hard coded with my own dir
    - `QMK Keyboard.ahk` `h::` now attempts to open `commLocation` if there is no Adobe project open
- Some loops now use `until` syntaxing
- `=>` notation has been used in some places
- Fixed `End::` erroring out if no project is open
- `Keyboard Shortcuts Adjustments.ahk` no longer uses a hardcoded dir for the `location` variable
- Removed `replaceChecklist.ahk` as `checklist.ahk` runs from the root dir now
- All timer scripts that make use of `SetTimer` now have an `OnExit` to stop all timers in the event of a reload/error/new instance
- Changed all instances of `if not x` to `if !x` for consistency

`right click premiere.ahk`
- Some loops now use `while` syntaxing
- Removed repeat code
- Added a timer that will check for and unstick the `Ctrl` key

`checklist.ahk`-- Alongside the changes listed above;
- Fixed not creating newly added `checklist.ini` settings
- Fixed `H:` number getting cut off when above 10 hours
- Now uses `floorDecimal()` for the `Hour` text so it ticks over more accurately
- Will now stop the timer & log information if a second instance is forcefully opened
- Added menu bar to:
    - Create a new checklist
    - Open other checklists
    - Toggle tooltips for the current project (if global `checklist.ahk` tooltips are enabled)
    - Toggle Dark Mode for the current project (if global dark mode is enabled)
    - Display `About` informational GUI
    - Open the current projects log file
    - Open the github repo
    - Show hours worked today, days worked & avg hours worked per day
    - Check for updates on both the stable and beta paths
- Version number moved to `About` menu bar GUI