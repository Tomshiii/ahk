# [![](https://bit.ly/3fjVx8t)](https://github.com/Tomshiii/ahk/tree/main) ahk [![](https://img.shields.io/github/v/release/Tomshiii/ahk)](https://github.com/tomshiii/ahk/releases/latest) [![](https://img.shields.io/github/last-commit/tomshiii/ahk/dev?label=last%20commit%20%28dev%29)](https://github.com/Tomshiii/ahk/commits/dev) [![](https://img.shields.io/github/license/tomshiii/ahk?color=orange)](https://github.com/tomshiii/ahk/blob/main/LICENSE)

This repo is a combination of all the scripts I use almost daily to help with either making content (videos or streaming related), or just speeding up mundane and random interactions with a computer.

- Video going over how AHK can help speed up [editing workflows](https://youtu.be/Iv-oR7An_iI)
- Video walking through an early version of the [Release v2.1 update](https://youtu.be/JF_WISVJsPU) || my [ahk v2.0 scripts](https://youtu.be/3rFDEonACxo) || older [ahk v1.1 scripts](https://youtu.be/QOztbpTe_Es)

[![](https://user-images.githubusercontent.com/53557479/149133968-6c1ff2e0-0140-4eda-95e3-e56164d263a4.png) ![](https://img.shields.io/youtube/channel/subscribers/UCJu2dToEHzuovY6suetkcdQ?style=flat)](https://www.youtube.com/c/tomshiii)

A lot of the code in the earliest versions of my scripts was either inspired by, or taken from [Taran from LTT](https://github.com/TaranVH/). His videos on ahk got me into fiddling around with it myself so many thanks. These scripts were then further elaborated on, then transformed into a `ahk v2.0` compliant script and now mostly contains my own tinkerings. Any scripts directly from Taran are labeled as such down below in the Explanation section (do note though that I have personally gone through them to make them function in `ahk v2.0`).

You can watch me use some of these scripts in action whilst I edit away on twitch when I stream on my bot account:

[![](https://user-images.githubusercontent.com/53557479/149135097-0f9ae87a-5157-4524-ae75-34b6aaf81c30.png) ![](https://img.shields.io/twitch/status/botshiii)](https://www.twitch.tv/botshiii)

### AHK Version Information:
This repo is to maintain work on the `ahk v2.0` versions of my scripts. These scripts **_will not_** work in `ahk v1.1`, the only versions of these scripts that will work with `ahk v1.1` are Releases [1.0](https://github.com/Tomshiii/ahk/releases/tag/v1.0)/[1.1](https://github.com/Tomshiii/ahk/releases/tag/v1.1)/[1.2](https://github.com/Tomshiii/ahk/releases/tag/v1.2) in this repo. They are _severely_ outdated, are practically missing everything found in the current versions of scripts, and those versions are no longer being maintained but you're free to try and backport any later additions if you're willing.

## QMK Keyboard:
My scripts have support for a secondary keyboard with [[QMK Keyboard.ahk]](https://github.com/Tomshiii/ahk/blob/main/QMK%20Keyboard.ahk) which along with the [`Hasu USB-USB converter`](https://geekhack.org/index.php?topic=109514.0) OR `a custom keyboard` (with `custom firmware`), allows you to use a secondary keyboard or numpad to launch completely different scripts than your main keyboard following [this tutorial by Taran from LTT](https://www.youtube.com/watch?v=GZEoss4XIgc). Any macros that have been moved to this script can be pulled out and placed in your own scripts without any issues.

## What to do:
1. Download and install [AHK v1.1](https://www.autohotkey.com/) then download [AHK v2.0 Beta](https://www.autohotkey.com/v2/).
2. Extract AHK v2.0 beta and rename either the 32bit or 64bit exe to just "AutoHotkey.exe". Then replace the default AutoHotkey.exe (usually found in `C:\Program Files\AutoHotkey`) with your new file from the 2.0 beta
   - Replace `Window Spy.ahk` with a v2.0 version found [here](https://github.com/steelywing/AutoHotkey-Release/blob/master/installer/source/WindowSpy.v2.ahk)
3. Download and install either; (You could technically just edit scripts in notepad if you really wanted to, but I honestly don't recommend it)
   - [Notepad++](https://notepad-plus-plus.org/downloads/)
     - Then download and install the [ahk language for notepad++](https://www.autohotkey.com/boards/viewtopic.php?t=50)
   - [VSCode](https://code.visualstudio.com/)
     - Then install an AHK extension within the program for a more complete package.
    ###### **_It is recommended you use VSCode as a lot of my variables have dynamic comments that can be viewed across the entire program that could help you understand what is going on._**
4. Save these scripts wherever you wish (I use "`E:\Github\ahk\`" if you want all the directory information to just line up without any editing) but if you wish to use a custom directory, simply change the `location :=` variable in `KSA.ahk` & `SD_functions.ahk` and most scripts should function as intended.
    ###### **_Although do note; some `Streamdeck AHK` scripts still have hard coded dir's and will error out if you try to run them from a different location._**
5. Take a look at [Keyboard Shortcuts.ini](https://github.com/Tomshiii/ahk/tree/main/KSA) to set your own keyboard shortcuts for programs as well as define coordinates for a few remaining imagesearches that cannot use variables for various reason, these `KSA` values are used to allow for easy adjustments instead of needing to dig through scripts!
6. Edit, then run any of the .ahk files to then use to your liking!
- If you don't have a secondary keyboard, don't forget to take a look through QMK Keyboard.ahk to see what functions you can pull out and put on other keys!

- Scripts that will work with no tinkering include ->
  - Alt Menu acceleration disabler
  - autodismiss error
#### Then be aware:
- Any scripts that still contain pixel coordinates instead of using variables (in either, `Click`, `MouseMove`, `ImageSearch`, `PixelSearch`, etc) rely not only on my monitor layout or the `coordinate mode` set, but also my workspace layout within premiere (or any applicable program) and will not necessarily work out of the box. They will require looking at the individual comments, as well as any accompanying AHK documentation (make sure you look at the ahk [v2.0](https://lexikos.github.io/v2/docs/AutoHotkey.htm) documentation and **NOT** the [v1.1](https://www.autohotkey.com/docs/AutoHotkey.htm) documentation) to get an idea of what is going on, then adjusting accordingly using `Window Spy` which gets installed alongside AHK. (an ahk v2.0 version of window spy can be found [here](https://github.com/steelywing/AutoHotkey-Release/blob/master/installer/source/WindowSpy.v2.ahk))
- All keyboard shortcuts within programs like Adobe Premiere/After Effects/OBS, etc that I need within a macro (eg. `^+5` to `highlight the media browser` within Premiere, or `d` for `select clip at playhead`) are definied within the [Keyboard Shortcuts.ini](https://github.com/Tomshiii/ahk/tree/main/KSA) file instead of just sending the shortcut itself, which are then assigned variables within the [Keyboard Shortcut Adjustments.ahk](https://git.io/Jicuy) script that is then included in other scripts. Edit that ini file with your own keyboard shortcuts (and assign any new values in the ahk script as well) to get things to work.

## Explanation:

#### [Keyboard Shortcuts.ini/Keyboard Shortcut Adjustments.ahk](https://github.com/Tomshiii/ahk/tree/main/KSA)
An ini file/ahk script combo for defining all keyboard shortcuts for programs that are then used within other scripts. Having them defined separately in an ini file allows for easy swapping of hotkeys without needing to dig through each and every macro/function that uses it. You do NOT need to run this ahk file, it is [`#Include(d)`](https://lexikos.github.io/v2/docs/commands/_Include.htm) in `Functions.ahk`

#### [My Scripts.ahk](https://github.com/Tomshiii/ahk/blob/main/My%20Scripts.ahk)
This script is the "central" script if you will. A lot of my windows scripts are here (and a hand full of scripts I use for editing).

#### [QMK Keyboard.ahk](https://github.com/Tomshiii/ahk/blob/main/QMK%20Keyboard.ahk)
A script to allow separate function for my secondary keyboard. A script originally created by [Taran](https://github.com/TaranVH/) that I've heavily modified to work for my own workflow and to function in ahk v2.0 (and cut down to only applicable buttons). Up until [Release v2.2.5.1](https://github.com/Tomshiii/ahk/releases/tag/v2.2.5.1) I used a small seconday numpad, but as of [Release v2.3+](https://github.com/Tomshiii/ahk/releases/tag/v2.3) I use a Planck Ez custom keyboard.
Check out [\Secondary Keyboard Files](https://github.com/Tomshiii/ahk/tree/main/Secondary%20Keyboard%20Files) for more information on how that works.

#### [Functions.ahk](https://github.com/Tomshiii/ahk/blob/main/Functions.ahk)
A sort of "hub" script that includes all [individual function files](https://github.com/Tomshiii/ahk/tree/main/Functions) into it so that ***it*** can then be [`#Include(d)`](https://lexikos.github.io/v2/docs/commands/_Include.htm) in other scripts. You don't need to manually run this file.
A function is defined similar to;
```autohotkey
/* These are comments that dynamically display information when displayed in VSCode,
but also serve as general comments for anyone else
 This function does something
 @param variableX is a value
 @param variableY is another value
 */
func(variableX, variableY)
{
  code(%&variableX%)
  code(%&variableY%)
}
```
We then [`#Include`](https://lexikos.github.io/v2/docs/commands/_Include.htm) `Functions.ahk` in other scripts so we can simply add `func("variableX", "variableY")` to scripts.

#### [autosave.ahk](https://github.com/Tomshiii/ahk/blob/main/autosave.ahk)
A script that will automatically save an Adobe Premiere Pro/After Effects project every 7.5min because Adobe's built in autosave is practically useless and fails to function a lot

#### [premiere_fullscreen_check.ahk](https://github.com/Tomshiii/ahk/blob/main/premiere_fullscreen_check.ahk)
A script that will restore Premiere back to its normal fullscreen mode if it gets stuck in a strange "further fullscreen" mode where you lose access to its window controls as well as ruining a lot of other coordinates for scripts

#### [Streaming.ahk](https://github.com/Tomshiii/ahk/tree/main/Stream)
A script I run as Admin while streaming to allow me to interact with obs via ahk (both need to be on the same elevation to interact).

#### [PC Startup.ahk](https://github.com/Tomshiii/ahk/blob/main/PC%20Startup.ahk)
A script that is run on PC startup to launch all my AHK scripts, as well as deal with some programs I need.

#### [Resolve_Example.ahk](https://github.com/Tomshiii/ahk/blob/main/Resolve_Example.ahk)
An example script for Davinci Resolve that has ported a few things from my premiere scripts to help you get started. This is very rough, thrown together and contains nowhere near the same amount of features.

#### [Alt_menu_acceleration_DISABLER.ahk](https://github.com/Tomshiii/ahk/blob/main/Alt_menu_acceleration_DISABLER.ahk)
A script from [Taran](https://github.com/TaranVH/) to disable the alt menu acceloration unless you _hold_ down the alt key.

#### [autodismiss error.ahk](https://github.com/Tomshiii/ahk/blob/main/autodismiss%20error.ahk)
A script from [Taran](https://github.com/TaranVH/) to remove an annoying dialogue box in premiere that treats you like a child.

#### [right click premiere.ahk](https://github.com/Tomshiii/ahk/blob/main/right%20click%20premiere.ahk)
A script from [Taran](https://github.com/TaranVH/) to move the playhead in premiere with the right mouse button.

#### [\Error Logs](https://github.com/Tomshiii/ahk/tree/main/Error%20Logs)
Anytime a macro/script encounters an error it will be logged in a txt file in this directory to help you catch anything that isn't working as intended so that in the event that the tooltip disappears too quickly, you can still dig in and see everything going on

Eg.
```
15:58:38.367 // `audioDrag()` encountered the following error: "User hasn't opened the required bin"
// Script: `My Scripts.ahk`, Line: 643
```