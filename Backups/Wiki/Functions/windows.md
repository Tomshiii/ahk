A list of `Windows.ahk` Functions complete with definitions.

These functions are used in various places across my scripts and are focused around getting information from things relating to windows, or just performing repetitive tasks.
***

## `youMouse()`
This function is used to skip `forward/backwards` in youtube.

The purpose of this script was to manipulate a youtube video, not only just with a mouse, but also even if youtube is the current active window.
```
youMouse( [tenS, fiveS] )
```
#### tenS
Type: String/Variable - Hotkey
> The hotkey for 10s skip in your direction of choice (`j/l`)

#### fiveS
Type: String/Variable - Hotkey
> The hotkey for 5s skip in your direction of choice (`Left/Right`)
***

## `monitorWarp()`
Warp anywhere on your desktop
```
monitorWarp( [x, y] )
```
#### x
Type: Integer
> The x value

#### y
Type: Integer
> The y value
***

## `moveWin()`
A function that will check to see if you're holding the left mouse button, then move any window around however you like.

If the activation hotkey is `Rbutton`, this function will minimise the current window.
```
moveWin( [key] )
```
#### key
Type: String/Variable - Hotkey
> This parameter is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
***

## `moveTab()`
This function allows you to move tabs within certain monitors in windows. I currently have this function set up to cycle between monitors 2 & 4.

By pressing `RButton` and then either `Xbutton1/2` will move the tab either way. This function will check for 2s if you have released the RButton, if you have, it will drop the tab and finish, if you haven't it will be up to the user to press the LButton when you're done moving the tab. This function has hardcoded checks for `XButton1` & `XButton2` and is activated by having the activation hotkey as just one of those two, but then right clicking on a tab and pressing one of those two.

As of firefox version 106, for this function to work it either requires you to follow [these instructions](https://www.askvg.com/tip-remove-tabs-search-arrow-button-from-firefox-title-bar/) to disable the tab search arrow, or it'll require you to make adjustments to the pixel values in this script.

The way my monitors are layed out in windows;

                            -------------
                            |    2      |
                            |           |
        -----               -------------
        |   | ------------- -------------
        | 3 | |    1      | |    4      |
        |   | |           | |           |
        |   | ------------- -------------
        -----

If you use a different monitor layout, this function may require heavy adjustment to work correctly.
***

## `getMouseMonitor()`
This function will grab the monitor that the mouse is currently within and return it as well as coordinate information in the form of a function object.

### Return Value
> Returns a function object containing; the monitor number, the left most pixel value, the right most pixel value, the top most pixel value and the bottom most pixel value.

Example #1
```autoit
;used in my main monitor (2560x1440)
monitor := getMouseMonitor()
MsgBox(monitor.monitor) ;returns 1
MsgBox(monitor.left) ;returns 0
MsgBox(monitor.right) ;returns 2560
MsgBox(monitor.top) ;returns 0
MsgBox(monitor.bottom) ;returns 1440
```
***

## `getTitle()`
This function gets and returns the title for the current active window. This function will ignore AutoHotkey GUIs.
```
getTitle( [&title] )
```
#### &title
Type: VarRef
> Produces a variable `title` that gets populated with the active window.
***

## `isFullscreen()`
This function is designed to check what state the active window is in.
```
isFullscreen( [&title, &full {window}] )
```
#### &title
Type: VarRef
> Produces a variable `title` that gets populated with the active window.

#### &full
Type: VarRef
> Produces a variable `full` that gets populated with `1` if the window is maximised & `0` if it is not.

#### window
Type: String/Variable - WinTitle
> Pass a window title into this variable if you wish to provide the function with the window instead of relying it to try and find it based off the active window. This paramater can be omitted.
***

## `moveXorY()`
A quick and dirty way to limit the axis your mouse can move.

This function has specific code for `XButton1/2` and must be activated with 2 hotkeys.
***

## `jumpChar()`
This function is to allow the user to simply jump 10 characters in either direction. Useful when `^Left/^Right` isn't getting you to where you want the cursor to be.
```
jumpChar( [{amount}] )
```
#### amount
Type: Integer
> This parameter is the amount of characters you want this function to jump, by default it is set to 10 and isn't required if you do not wish to override this value.
***

## `titleBarDarkMode()`
This function will convert a windows title bar to a dark/light theme if possible.

Original code found [here](https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661).
```
titleBarDarkMode( [hwnd, {dark}] )
```
#### hwnd
Type: String/Variable
> This parameter is the hwnd value of the window you wish to alter.

#### dark
Type: Boolean
> This parameter is a toggle that allows you to call the inverse of this function and return the title bar to light mode. This parameter can be omitted for dark mode, otherwise pass false for light mode.
***

## `buttonDarkMode()`
This function will convert GUI buttons to a dark/light theme.

Original code found [here](https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661).
```
buttonDarkMode( [ctrl_hwnd, {DarkorLight}] )
```
#### ctrl_hwnd
Type: String/Variable
> This parameter is the hwnd value of the button you wish to alter.

#### DarkorLight
Type: String
> This parameter is a toggle that allows you to call the inverse of this function and return the button to light mode. This parameter can be omitted for dark mode, otherwise pass "Light".
***

## `menuDarkMode()`
This function will convert GUI menus to dark mode/light mode.

Original code found [here](https://www.autohotkey.com/boards/viewtopic.php?f=13&t=94661).
```
menuDarkMode( [{DarkorLight}] )
```
#### DarkorLight
Type: Boolean
> This parameter is a toggle that allows you to call the inverse of this function and return the menu to light mode. This parameter can be omitted for dark mode, otherwise pass "0"
***

## `fastWheel()`
This function facilitates accelerated scrolling. If the window under the cursor isn't the active window when this function is called, it will activate it.
***

## `getPremName()`
This function will grab the title of Premiere if it exists and check to see if a save is necessary.
```
getPremName( [&premCheck, &titleCheck, &saveCheck] )
```
#### &premCheck
Type: VarRef
> This parameter is the title of premiere, we want to pass this value back to the script that called it.

#### &titleCheck
Type: VarRef
> This parameter is checking to see if the premiere window is available to save (if it's possible), we want to pass this value back to the script. If the title contains necessary values, it will contain a number, otherwise it will contain `0`.

#### &saveCheck
Type: VarRef
> This parameter is checking for a * in the title to say a save is necessary, we want to pass this value back to the script. If a save is necessary, it will contain a number, otherwise it will contain `0`.
***

## `getAEName()`
This function will grab the title of After Effects if it exists and check to see if a save is necessary
```
getAEName( [&aeCheck, &aeSaveCheck] )
```
#### &aeCheck
Type: VarRef
> This parameter is the title of after effects, we want to pass this value back to the script.

#### &aeSaveCheck
> This parameter is checking for a * in the title to say a save is necessary, we want to pass this value back to the script. If a save is necessary, it will contain a number, otherwise it will contain `0`.
***

## `getID()`
A function to grab the ID of the active window.
```
getID( [&id] )
```
#### &id
Type: VarRef
> This parameter is the processname of the active window, we want to pass this value back to the script.
***

## `GetExplorerPath()`
A function to extract the directory path of an open explorer window.
```
GetExplorerPath( [{hwnd}] )
```
#### hwnd
Type: Integer
> This parameter is the hwnd number of the window you wish to focus. If no hwnd number is provided, the function will determine the hwnd of the active window instead.
***

## `disc()`
This function uses an imagesearch to look for buttons within the right click context menu to perform various tasks.

This function has code so that, if the `button` variable, is `DiscReply.png`, will find and disable the `@ping`
```
disc( [button] )
```
#### button
Type: String - Filename
> This parameter is the full filename of the button of choice. ie. `DiscEdit.png` or `DiscReply.png`. Will require screenshots of said property in the appropriate ImageSearch folder.
***

## `discUnread()`
This function will search for and automatically click on either unread servers or unread channels depending on which image you feed into the function.
```
discUnread( [which] )
```
#### which
Type: Integer
> If you feed in nothing it will search for the first unread server and click it. If you feed in `2` it will search for the first unread channel and click on it. Will require screenshots of said property in the appropriate ImageSearch folder.
***

## `vscode()`
A function to quickly naviate between files in VSCode.

As this function is designed for my repo, it has code so that, if the second activation key is the `function hotkey` (as defined in KSA), it will do extra things to expand that folder.

For this script to work [explorer.autoReveal] must be set to `false` in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal")
```
vscode( [script] )
```
#### script
Type: Integer
> This parameter is the amount of down inputs the script needs to input to get to the required script. Will default to 0.
***