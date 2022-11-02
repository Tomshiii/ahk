`QMK.ahk` is built entirely under the premise of optimisation and functionality - it helps make a secondary keyboard feel like an extension of the first and eliminates any feelings of clunkyness and weird behaviour.

For this script to function correctly, you'll need either a keyboard with custom firmware, or a keyboard compatible with a `HASU USB-USB Converter` - from there you'll need to install custom firmware.

This custom firmware allows us to wrap each keystroke IN another keystroke. For example:

A normal keystroke as seen by AHK is as follows, we'll use the `k` key:

- `k Down` followed by `k Up` when the key is released.

With this custom firmware, AHK sees the following instead:

- `F24 Down` `k Down` followed by `k Up` `F24 Up` when the key is released.

This allows us to define separate macros/functions through the use of the below code for program specific functions:
```autohotkey
#HotIf WinActive("ahk_exe *insert program here*") and getKeyState("F24", "P")
k::func()
```
or the below code for macros that can be used at all times:
```autohotkey
#HotIf getKeyState("F24", "P")
k::func()
```
***

# Contributions & Credits
The idea to do this was thought up by [TaranVH](https://github.com/TaranVH/2nd-keyboard) a previous editor for LTT. You can watch his [video here](https://www.youtube.com/watch?v=GZEoss4XIgc)

**

The files needed for me to make this happen with MY secondary keyboard are the generous works of ***JivanYatra*** and without their kindness and help, I would still be stuck on a tiny little numpad. Huge thank you to them for all of their hard work as well as all the code and custom firmware to make it all happen.

- Jivanyatra's github > https://github.com/jivanyatra
- The repo containing information about this firmware > https://github.com/jivanyatra/planck_ez_glow_macros
***
# Hotkey Definitions
While most keys on my keyboard are linked to functions we've defined in other pages, there are some keys that just have specific code. I will not be explaining every single hotkey that isn't linked to a function as most are relatively straight forward

## `newWin()`
This function is specifically designed for my secondary keyboard and works in tandom with the [`switchTo()`](https://github.com/Tomshiii/ahk/wiki/switchTo-Functions) functions.

If the desired program isn't already open, it will run a first instance, if the desired program is already open, it will run a second instance without disrupting the first.
```
newWin( [classorexe, activate, runval] )
```
#### classorexe
Type: String
> This parameter is just defining whether the function is trying to grab the `ahk_class` or the `ahk_exe` value of the desired program.

#### activate
Type: String
> This parameter is whatever usually comes after the `ahk_class` or the `ahk_exe` value of the desired program.

#### runval
Type: String - Filepath
> This parameter is whatever you would normally need to feed into a `Run()` command to open the desired program. Either a full file path, or something along the lines of `explorer.exe`, `firefox.exe`, etc.
***

## #HotIf `getKeyState("F24", "P")`
*Everything after this line will only happen on the secondary keyboard that uses F24, but will work in any program*

## `h::`
This macro will read the title of an active `Premiere Pro` or `After Effects` window and open the folder for the open project in windows explorer. If no project is open, it will open `commLocation*` in windows explorer.

**`commLocation` is set at the top of [`KSA.ahk`](https://github.com/Tomshiii/ahk/blob/main/lib/KSA/Keyboard%20Shortcut%20Adjustments.ahk)*
***

## `b::`
This macro will present two inputboxes asking for the user to provide two 24h timecodes. Once provided, this macro will determine the difference between those two timecodes. It will then display that difference in a tooltip & copy the result to the clipboard.
***
