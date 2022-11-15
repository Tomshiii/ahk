A list of `General.ahk` Functions complete with definitions.

This script not only contains a stew of functions, classes, as well as some group assignments used in other places.
***

## class ptf {
`Point to File`, this class contains all directory and file locations that I can possibly assign. Keeping all definitions in the one place allows for easier adjusting of file locations in the future, as well as an easier time for another user to come through and adjust.

#### `ptf.Variable`
Example;
```
;for directory locations
ptf.SupportFiles ;passes: A_WorkingDir "\Support Files"
```

#### `ptf.files["variable"]`
Example;
```
;for absolute file locations
ptf.files["settings"] ;passes: A_MyDocuments "\tomshi\settings.ini"
```
***

## class browser {
This class contains a set of key/value pairs of browser `winTitles` & `classes`. Currently contains information for; firefox, chrome & msedge

Example;
```autohotkey
;for winTitle
broswer.winTitle["firefox"] ;passes: ahk_exe firefox.exe

;for class
browser.class["firefox"] ;passes: ahk_class MozillaWindowClass
```
***

## GroupAdd
The script then goes on to define a browser group, and an editor group.
***

## class coord {
This class contains 3 different coordinate mode definitions to make setting coordmodes a bit easier during coding.

```
coord.s() ; sets coordmode("pixel", "screen")
coord.w() ; sets coordmode("pixel", "window")
coord.c() ; sets coordmode("caret", "window")
```
***

## class tool {
This class contains two tooltip functions that help with tooltip creation and management.

## `Cust()`
This function allows the creation of a tooltip with any message, for a custom duration. This tooltip will then follow the cursor and only redraw itself if the user has moved the cursor.
```
tool.Cust( [message, {timeout, find, x, y, WhichToolTip}] )
```
#### message
Type: String
> This parameter is whatever you wish the tooltip to display.

#### timeout
Type: Integer/Float
> This parameter is the duration you wish the tooltip to last. By default, this value is set to `1000ms` (`1s`).

> If you wish to give this variable in ms, pass in a whole integer, eg `2000`, if you wish to give this variable in seconds, pass this variable as a float, eg `2.0`.

#### find
Type: Boolean
> This variable determines whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 (or true) for this variable if you do, or omit it if you don't.

#### x
Type: Integer
> The x coordinate you want the tooltip to be placed.

> If you pass either an `x/y` coordinate, the tooltip will no longer follow the mouse.

#### y
Type: Integer
> The y coordinate you want the tooltip to be placed.

> If you pass either an `x/y` coordinate, the tooltip will no longer follow the mouse.

#### WhichToolTip
Type: Integer
> This parameter allows you to indicate which tooltip you want this call of the function to be. Must be a number between 1 & 20. If unspecified, the number is 1.

If the user passes either an `x or y` value to this function, it will no longer follow the cursor. If you wish to replicate typical `ToolTip()` placement behaviour, follow Example #2 below.

Example #1
```
tool.c("image", 2.0, 1) ; Produces a tooltip that says "Couldn't find image" that will follow the cursor for 2 seconds
```

Example #2
```
tool.Cust("hello",,, MouseGetPos(&x, &y) x + 15, y) ; Produces a tooltip that says "hello" next to the cursor when called and will stay there for 1 second
```

## `Wait()`
This function will check to see if any tooltips are active and will wait for them to disappear before continuing.
```
tool.Wait( [{timeout}] )
```
#### timout
Type: Integer
> This parameter allows you to pass in a time value (in seconds) that you want `WinWaitClose` to wait before timing out. This value can be omitted and does not need to be set.
***

## class block {
This class contains 2 different block input mode definitions to make setting blockinputs a bit easier during coding.
```
block.On() ; Blocks all user inputs
block.Off() ; Enables all user inputs
```
***

## `mousedragNotPrem`
This function  allows the user to press a button (best set to a mouse button, eg. `Xbutton1/2`), this script then changes to the desired tool and clicks so the user can drag. Then once the user releases, the function will swap back to a desired tool.
```
mousedragNotPrem( [tool, toolorig] )
```
#### tool
Type: String/Variable - Hotkey
> This parameter is the hotkey you want the program to swap TO (ie, hand tool, zoom tool, etc). (consider using values in KSA)

#### toolorig
Type: String/Variable - Hotkey
> This parameter is the button you want the script to press to bring you back to your tool of choice. (consider using values in KSA)
***

## `errorLog()`
This function logs errors when a script enters a predetermined block of code that would indicate something went wrong.

Errors are logged in `.txt` files in `..\Error Logs` by default. They are separated by day.

If a file for the current day doesn't exist, this function will create it, and capture a bunch of system information that could be useful when it comes to determining problems.

If a file for the current day does exist, the current log will simply be appended to the end of the file.
```
errorLog( [{err, backupFunc, backupErr, backupLineFile, backupLineNumber}] )
```
#### err
Type: Error Object
> This variable is an Error Object you can simply pass into the function to prefill all the required information. These error objects are usually found in `try{}/catch{}` blocks.
>
> If the user wishes to log an error outside of a block of code that would throw an Error Object, they can manually input the required information in the remaining parameters and omit this parameter.

#### backupFunc
Type: String/Variable
> If the user is passing in an Error Object, there is code to still use this variable in the event that the object's `.What` is empty so it is good practice to still include this parameter.
>
> If the user isn't passing in an Error Obkect, this variable is to alert the log if it's being called from a function or a hotkey. If you're calling errorLog() from a function, simply pass `A_ThisFunc "()"`, if you're calling from a hotkey, pass `A_ThisHotkey "::"`.

#### backupErr
Type: String
> This parameter is a description of the error. This parameter is only necessary if the user isn't passing in an Error Object

#### backupLineFile
Type: String/Variable - Filepath
> This parameter is the filepath of the script CALLING the function. Simply pass `A_LineFile`. This parameter is only necessary if the user isn't passing in an Error Object

#### backupLineNumber
Type: Integer
> This parameter is the line number where the error is occuring. Simply pass `A_LineNumber`. This parameter is only necessary if the user isn't passing in an Error Object
***

## `getHotkeys()`
This function is designed to return the names of the first & second hotkeys pressed when two are required to activate a macro.

If the hotkey used with this function is only 2 characters long, it will assign each of those to &first & &second respectively. If one of those characters is a special key (ie. ! or ^) it will return the virtual key so `KeyWait` will still work as expected.
```
getHotkeys( [&first, &second] )
```
#### first
Type: VarRef
> This parameter is the variable that will be filled with the first activation hotkey.

#### second
Type: VarRef
> This parameter is the variable that will be filled with the second activation hotkey.

Example
```autoit
RAlt & p::
{
    getHotkeys(&first, &second)
    MsgBox(first) ; returns "RAlt"
    MsgBox(second) ; returns "p"
}

!p::
{
    getHotkeys(&first, &second)
    MsgBox(first) ; returns "vk12"
    MsgBox(second) ; returns "p"
}
```
***

## `floorDecimal()`
`Floor()` is a built in math function of ahk to round down to the nearest integer, but when you want a decimal place to round down, you don't really have that many options. This function will allow us to round down after a certain amount of decimal places.

Original code [found here](https://www.autohotkey.com/board/topic/50826-solved-round-down-a-number-with-2-digits/).
```
floorDecimal( [num, dec] )
```
#### num
Type: Integer
> This parameter is the number you want this function to evaluate.

#### dec
Type: Integer
> This parameter is the amount of decimal places you wish the function to evaluate to.
***

## `reload_reset_exit()`
A function that will loop through and either `reload`, `hard reset` (by rerunning the file directly) or `exiting` (by force closing the process) all active AutoHotkey scripts.

This function will ignore `checklist.ahk` unless you set `includeChecklist`.
```
reload_reset_exit( [which, {includeChecklist}] )
```
#### which
Type: String
> This parameter determines whether the loop will reload, reset or exit all scripts.

#### includeChecklist
Type: Any
> This parameter determines whether the loop will include `checklist.ahk`.
***

## `detect()`
A function to cut repeat code and set `DetectHiddenWindows` & `SetTitleMatchMode`.
```
detect( [{windows, title}])
```
#### windows
Type: Boolean
> This parameter determines whether you wish to enable or disable DetectHiddenWindows. It defaults to `true` and can be omitted.

#### title
> This parameter determines what `SetTitleMatchMode` you wish to set. It defaults to `2` and can be omitted.
***

## `pauseautosave()`
This function toggles a pause on the `autosave.ahk` script.
***

## `pausewindowmax()`
This function toggles a pause on the `premiere_fullscreen_check.ahk` script.
***

## `ScriptSuspend()`
This function will suspend/unsuspend other scripts.

Original code for this function [found here](https://stackoverflow.com/questions/14492650/check-if-script-is-suspended-in-autohotkey).
```
ScriptSuspend( [ScriptName, SuspendOn] )
```
#### ScriptName
Type: String
> The name of the script you wish to suspend. eg. `My Scripts.ahk`.

#### SuspendOn
Type: Boolean
> A true/false value determining whether to suspend or unsuspend the requested script.
***

## `refreshWin()`
A function to close a window, then reopen it in an attempt to refresh its information (for example, a txt file).

If the user passes `"A"` into both of the variables to indicate they want to focus on the active window and said active window is either `Notepad*` or `Windows Explorer`, there is added code in this function to retrieve the filepath of said window and reopen it automatically.

**If there are multiple notepad windows open, this function will refresh all of them.*
```
refreshWin( [window, runTarget] )
```
#### window
Type: String/Variable
> This parameter is the window you wish to target and close.

#### runTarget
Type: String - Filepath
> This parameter is the path of the file you wish to open.
***

## `SplitPathObj()`
This function is a psudo replacement to the built in function `SplitPath` where instead of needing to remember the correct amount of commas for what you need, all variables get returned as an object instead.
```
SplitPathObj( [path] )
```

#### Path
Type: String
> This parameter is the path you wish to have split by the function.

Example:
```autohotkey
path := "E:\Github\ahk\My Scripts.ahk"
script := SplitPathObj(path)

script.Name       ;returns `My Scripts.ahk`
script.Dir        ;returns `E:\Github\ahk`
script.Ext        ;returns `ahk`
script.NameNoExt  ;returns `My Scripts`
script.Drive      ;returns `E:`
```