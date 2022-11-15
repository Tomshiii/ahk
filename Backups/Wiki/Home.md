Welcome to the documentation for Tomshi's ahk scripts!

These scripts are designed to make working within `Adobe Premiere Pro` and `Adobe After Effects` more optimised and efficient. They also contain a bunch of features to make navigating windows easier.

### AHK Version Information:
This repo is to maintain work on the `ahk v2.0` versions of my scripts. These scripts **_will not_** work in `ahk v1.1`, the only versions of these scripts that will work with `ahk v1.1` are Releases [1.0](https://github.com/Tomshiii/ahk/releases/tag/v1.0)/[1.1](https://github.com/Tomshiii/ahk/releases/tag/v1.1)/[1.2](https://github.com/Tomshiii/ahk/releases/tag/v1.2) in this repo. They are _severely_ outdated, are practically missing everything found in the current versions of scripts, and those versions are no longer being maintained but you're free to try and backport any later additions if you're willing.

## Getting Started

1. Download and install [AHK v1.1](https://www.autohotkey.com/) then download and install [AHK v2.0 beta](https://www.autohotkey.com/v2/). (I think on the latest betas of v2 you can just install v2)
2. Download and install either; (You could technically just edit scripts in notepad if you really wanted to, but I honestly don't recommend it)
   - [Notepad++](https://notepad-plus-plus.org/downloads/)
     - Then download and install the [ahk language for notepad++](https://www.autohotkey.com/boards/viewtopic.php?t=50)
   - [VSCode](https://code.visualstudio.com/)
     - Then install an AHK extension within the program for a more complete package.
    ###### **_It is recommended you use VSCode as a lot of my functions have dynamic comments that can be viewed across the entire program that could help you understand what is going on._**
3. Download these scripts by either checking out the latest [release](https://github.com/tomshiii/ahk/releases/latest) or by cloning the repo (in either VSCode or your git manager of choice), then save them wherever you wish.
    ###### **_Although do note; some [`Streamdeck AHK`](https://github.com/Tomshiii/ahk/tree/main/Streamdeck%20AHK) scripts still have hard coded dir's as they are intended for my workflow and may error out if you try to run them from a different location._**
4. Take a look at [Keyboard Shortcuts.ini](https://github.com/Tomshiii/ahk/tree/main/lib/KSA) to set your own keyboard shortcuts for programs as well as define some coordinates for a few remaining imagesearches that cannot use variables for various reason, these `KSA` values are used to allow for easy adjustments instead of needing to dig through scripts!
5. Take a look at [General.ahk](https://github.com/Tomshiii/ahk/tree/main/lib/Functions/General.ahk) in the class `class ptf {` to adjust all assigned filepaths!
6. Run `My Scripts.ahk` to get started! (it's the main "hub" script and handles changing the root directory)
7. You can then edit and run any of the .ahk files to use to your liking!
8. Adjust the `PC Startup.ahk` file ***or*** create shortcuts to individual scripts in your startup folder (which can be accessed by pressed `win + r` and then typing in `shell:startup`)
    - If you don't have a secondary keyboard, don't forget to take a look through QMK Keyboard.ahk to see what functions you can pull out and put on other keys!
***

This wiki contains documentation for just about everything relating to my scripts - feel free to poke around to get a better understanding of what they can do!

#### Just to be aware:
- Any scripts that still contain pixel coordinates instead of using variables (in either, `Click`, `MouseMove`, `ImageSearch`, `PixelSearch`, etc) rely not only on my monitor layout or the `coordinate mode` set, but also my workspace layout within premiere (or any applicable program) and will not necessarily work out of the box. This wiki aims to rectify some of that concern but might not be perfect, don't be scared to look at the individual comments, as well as any accompanying AHK documentation (make sure you look at the ahk [v2.0](https://lexikos.github.io/v2/docs/AutoHotkey.htm) documentation and **NOT** the [v1.1](https://www.autohotkey.com/docs/AutoHotkey.htm) documentation) to get an idea of what is going on, then adjusting accordingly using `WindowSpy` which gets installed alongside AHK.
- All keyboard shortcuts within programs like Adobe Premiere/After Effects/OBS, etc that I need within a macro (eg. `^+5` to `highlight the media browser` within Premiere, or `d` for `select clip at playhead`) are definied within the [Keyboard Shortcuts.ini](https://github.com/Tomshiii/ahk/tree/main/lib/KSA) file instead of just sending the shortcut itself, which are then assigned variables within the [Keyboard Shortcut Adjustments.ahk](https://github.com/Tomshiii/ahk/blob/main/lib/KSA/Keyboard%20Shortcut%20Adjustments.ahk) script that is then included in other scripts. Edit that ini file with your own keyboard shortcuts (and assign any new values in the ahk script as well) to get things to work.