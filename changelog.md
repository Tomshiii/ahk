# <> Release 2.6 - Dark Mode (sorta) + Two New Scripts
This release brings along two new scripts; `gameCheck.ahk` & `Multi-Instance Close.ahk`

- `gameCheck.ahk` is a script that will automatically detect when a predetermined game is currently active and suspend `My Scripts.ahk`. This is important because `My Scripts.ahk` contains a bunch of macros that really don't play nice to games and cause a lot of basic functionality in them to break. This script will also detect when the game is no longer the active window and unsuspend `My Scripts.ahk`. Games may be periodically added to this script but feel welcome to add your own list!
- `Multi-Instance Close.ahk` is a script that will periodically check for duplicate instances of any autohotkey scripts and close one of them. Even if you use `#SingleInstance Force` reloading scripts can sometimes cause a second instance to slip open. This script will hopefully mitigate the odd behaviour that occurs when this happens by closing any duplicates.

Alongside those two scripts, this update brings along a dark theme to certain GUI elements. AHK is rather limited in what it can apply in a modern way but a global dark mode option can now be enabled in `settingsGUI()`

## > My Scripts
- Changed `F14::` `show more options` hotkey -> `F18` due to it causing issues with `F14 & WheelDown/WheelUp::`
- `F14 & WheelDown/WheelUp::` now calls `fastWheel()`
- Added the ability to toggle `CapsLock` by double tapping it
- Added `#+^r::` to hard refresh all open `.ahk` scripts (not including `checklist.ahk`)
    - Added `hardReset()` for this and so it can be used elsewhere
- `#+r::` will now create a list of open `.ahk` scripts and tell them to reload instead of requiring hard coded values
- `SC03A & c::` now pastes the string instead of using a `Send{}` type to increase performance
- `getMonitor()` in `#c::` now returns a function object instead of a large list of variables

## > Functions
- Added `floorDecimal()` to round down after a determined amount of decimal places
- Added `blockOff()` to `getTitle()` and `isFullscreen()` so that in the event they fail, the user is not potentially stuck
- Added more colours for `audioDrag()`
- Added a check in `musicGUI()` to make sure to music folder actually exists
- Added `fastWheel()` to replace the simple `SendInput("{WheelDown/Up 10}")` and allow the function to focus the window under the cursor if it isn't currently the active window when called
- Fixed hard coded dir in `switchToDisc()`
- Fixed some incorrect information in `hotkeysGUI()`
- `switchToAE()` now contains more elaborate code to be able to open the `.aep` file for the current Premiere project even once AE is already open
- `activeScripts()` now starts a timer to check the suspended state of `My Scripts.ahk` to update the checkbox value
- Condensed most `OnEvent`'s for `activeScripts()` to one singular function
- `getMouseMonitor()` now returns a function object and passes back all information
- `toolCust()` can now take custom `x` & `y` coordinates. They are unset by default and can be omitted. It can also accept the `WhichToolTip` parameter from the actual `ToolTip` function
- `moveXorY()` tooltips will no longer flicker

`zoom()`
- Now sets it's variable presets in an array to remove the need for multiple variables
- Now resets toggle values after 10 seconds

`settingsGUI()`
- Minor GUI tweaks
- Fixed bug that caused function to error if non numeric values were entered into the edit boxes
- Now has an option to globally enable/disable reminder tooltips for `checklist.ahk`
- Moved `Current working dir:` to the status bar
    - Status bar now also shows whether `My Scripts.ahk` is active or suspended
- Ability to add game information to `gameCheck.ahk`

## > Other Changes
- Fix all dynamic comments
- Adjusted positioning of tray menu items for `My Scripts.ahk` & `autosave.ahk`
- Added `commLocation :=` to `Keyboard Shortcut Adjustments` for the user to manually input their own commission working dir (if they have one) so my scripts don't need to be hard coded with my own dir
    - `QMK Keyboard.ahk` `h::` now attempts to open `commLocation` if there is no Adobe project open
- Some loops now use `until` syntaxing
- Some loops in `right click premiere.ahk` now use `while` syntaxing
- `=>` notation has been used in some places

`replaceChecklist.ahk`
- Will now ignore backup folders
- Fixed bug causing "Yes to All" to not function correctly
- Fixed typo causing this script to create a different `\backup` folder than `checklist.ahk`

`checklist.ahk`
- Fixed not creating newly added `checklist.ini` settings when it copies a newer version from the working dir (you will encounter errors until you're on `checklist.ahk's local-v2.5.3` or greater and generate a .ini file)
- Fixed `H:` number getting cut off when above 10 hours
- Moved all functions to the bottom of the script to increase readability
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