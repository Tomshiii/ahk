`My Scripts.ahk` is the main script of my entire repo, it's what helps facility most of the "experience" that helps make my collection of scripts seem less like singular macros and more like an entire package.

Alongside all the functions that run [on startup](https://github.com/Tomshiii/ahk/wiki/Startup-Functions), this script also contains a bunch of macros of it's own.
***

`My Scripts.ahk` starts off by declaring `MyRelease`, a global variable to dictate the release version you are running. We use this variable in some functions.

Then we define some settings.

* `#SingleInstance Force` to ensure only one instance of these scripts is open.
* `SetWorkingDir A_ScriptDir` to set a consistent working directory.
* `SetNumLockState "AlwaysOn"` to always have numlock enabled (a personal preference).
* `SetCapsLockState "AlwaysOff"` to set CapsLock to be always disabled. This doesn't stop us from using it as a hotkey.
* `SetScrollLockState "AlwaysOff"` to set ScrollLock to be always disabled. This doesn't stop us from using it as a hotkey.
* `SetDefaultMouseSpeed 0` to set the default mouse speed to be instant
* `SetWinDelay 0` to set the default window delay to be instant.

Then we set our tray icon, `#Include` our functions & `right click premiere.ahk` and we're done.

From there, this script will run through it's [startup functions](https://github.com/Tomshiii/ahk/wiki/Startup-Functions) before finally hitting its hotkey definitions.

On this page, I will be referring to macros by their `;Hotkey;` tag and not their keybindings. This is to reduce the need for change in the event that a keybinding changes.
***

### Table of Contents:
* [Windows Macros](#Windows-Macros)
* [Launch Programs](#Launch-Programs)
* [Other](#Other)
    * #HotIf
        * [`WinActive(windows explorer)`](#hotif-winactivewindows-explorer)
        * [`WinActive(VSCode)`](#hotif-winactivevscode)
        * [`WinActive(firefox)`](#hotif-winactivefirefox)
        * [`WinActive(Discord)`](#hotif-winactivediscord)
        * [`WinActive(Photoshop)`](#hotif-winactivephotoshop)
        * [`WinActive(After Effects)`](#hotif-winactiveafter-effects)
        * [`WinActive(Premiere Pro)`](#hotif-winactivepremiere-pro)
            * [Mouse Scripts](#mouse-scripts)
* [Other - NOT an editor](https://github.com/Tomshiii/ahk/wiki/My-Scripts.ahk#other---not-an-editor)
***

# Windows Macros

### #SuspendExempt
*The below hotkeys will function even while the script is suspended.*

## `reloadHotkey`
runs: [`reload_reset_exit("reload")`](https://github.com/Tomshiii/ahk/wiki/General-Functions#reload_reset_exit)

## `hardresetHotkey`
runs: [`reload_reset_exit("reset")`](https://github.com/Tomshiii/ahk/wiki/General-Functions#reload_reset_exit)

## `panicExitHotkey`
runs: [`reload_reset_exit("exit")`](https://github.com/Tomshiii/ahk/wiki/General-Functions#reload_reset_exit)

## `panicExitALLHotkey`
runs: [`reload_reset_exit("exit", true)`](https://github.com/Tomshiii/ahk/wiki/General-Functions#reload_reset_exit)

## `settingsHotkey`
runs: [`settingsGUI()`](https://github.com/Tomshiii/ahk/wiki/GUI)

## `activescriptsHotkey`
runs: [`activeScripts(MyRelease)`](https://github.com/Tomshiii/ahk/wiki/GUI)

## `handyhotkeysHotkey`
runs [`hotkeysGUI()`](https://github.com/Tomshiii/ahk/wiki/GUI)

## `suspendHotkey`
This hotkey will toggle suspend `My Scripts.ahk`. Useful when booting up a game that hasn't been added to gameCheck yet.

### #SuspendExempt false
*everything below here will no longer work while script is suspended*

## `centreHotkey`
This hotkey will centre the active window in the middle of the monitor it is active within. If pressed a second time on the same window, it will move it to the centre of the main monitor.

If the active window is a youtube window, it will be slightly larger to give the user more video viewing space.

## `fullscreenHotkey`
This hotkey will check the state of the active window - if it is not currently fullscreen, it will maximise it, if it is, it will unmaximise it.

## `jump10charLeftHotkey` & `jump10charRightHotkey`
These hotkeys will run: [`jumpChar()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#jumpchar).

## `refreshWinHotkey`
runs [`refreshWin()`](https://github.com/Tomshiii/ahk/wiki/General-Functions#refreshwin) passing the active window as the desired target. If the target window is `Notepad.exe` or `explorer.exe` it is able to determine the filepath of the current window and reopen it.
***

# Launch Programs

## `windowspyHotkey`
runs: [`switchToWindowSpy()`](https://github.com/Tomshiii/ahk/wiki/switchTo-Functions)

## `vscodeHotkey`
runs: [`switchToVSC()`](https://github.com/Tomshiii/ahk/wiki/switchTo-Functions)

## `streamdeckHotkey`
runs: [`switchToStreamdeck()`](https://github.com/Tomshiii/ahk/wiki/switchTo-Functions)

## `taskmanagerHotkey`
Sends `^+{Esc}` to open the taskmanager.

## `excelHotkey`
runs: [`switchToExcel()`](https://github.com/Tomshiii/ahk/wiki/switchTo-Functions)

## `ahkdocuHotkey`
Opens the [ahk documentation](https://lexikos.github.io/v2/docs/AutoHotkey.htm)

## `ahksearchHotkey`
Attempts to search the highlighted text in the ahk documentation.
***

# Other

## `moveXHotkey` & `moveYHotkey`
run: [`moveXorY()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#movexory)

## #HotIf `WinActive(windows explorer)`
*The below hotkeys only activate while windows explorer is the active window.*

## `explorerbackHotkey`
Remaps `!{Up}` to another button. (I have it set to `WheelLeft`)

## `showmoreHotkey`
This hotkey was designed to automatically open the `show more options` menu in windows 11. Ultimately I ended up using a different method and now that menu is my default, but the code for this hotkey is still rather robust.

## #HotIf `WinActive(VSCode)`
*The below hotkeys only activate while VSCode is the active window.*

## `vscodeHotkeys`
run: [`vscode()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#vscode)

## `vscodesearchHotkey`
I have a habit in VSCode of trying to use `^f` to search, while the explorer window is open instead of the code window. To combat this I made a hotkey that would highlight the code window first. In using that I realised that it would start the search field with the previous search. I didn't like this either and only wanted it to contain text if I had text highlighted.

For this hotkey to work `editor.emptySelectionClipboard` must be set to false within VSCode. Because otherwise, sending `^c` to copy text while nothing is selected will copy the entire line which makes it impossible to check and see if the user has something highlighted.

## `vscodecutHotkey`
This hotkey is to return the usual experience of pressing `^x` in vscode (it will delete the entire line if nothing is selected). This experience only occurs while `editor.emptySelectionClipboard` is enabled however, so as we have it disabled, we needed a workaround.

## #HotIf `WinActive(firefox)`
*The below hotkeys only activate while firefox is the active window.*

## `pauseyoutubeHotkey`
This hotkey will search for and pause a youtube video if it exists.

## `numpadytHotkey`
These hotkey assignments disable the numpad while youtube is the active window to stop the user from accidentally bumping the numpad and teleporting somewhere in the video.

## `movetabHotkey`
runs: [`moveTab()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#movetab)

## #HotIf `WinActive(Discord)`
*The below hotkeys only activate while discord is the active window.*

## `discHotkeys`
These hotkeys will run their respective: [`disc()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#disc) function.

## `discserverHotkey`
runs: [`discUnread()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#discunread)

## `discmsgHotkey`
runs: [`discUnread(2)`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#discunread)

## `discdmHotkey`
This hotkey will click a the dm button on discord

## #HotIf `WinActive(Photoshop)`
*The below hotkeys only activate while Adobe Photoshop is the active window.*

## `fileTypeHotkeys`
These hotkeys run: [`psType()`](https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#pstype) with the requested filetype as their parameters

## `photoopenHotkey`, `photoselectHotkey` & `photozoomHotkey`
runs: [`mousedragNotPrem()`](https://github.com/Tomshiii/ahk/wiki/General-Functions#mousedragnotprem) with different tools

## #HotIf `WinActive(After Effects)`
*The below hotkeys only activate while Adobe After Effects is the active window.*

## `aetimelineHotkey`
runs: [`aetimeline()`](https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#aetimeline)

## `aeselectionHotkey`
runs: [`mousedragNotPrem()`](https://github.com/Tomshiii/ahk/wiki/General-Functions#mousedragnotprem)

## `aepreviousframHotkey` & `aenextframeHotkey`
Send the hotkey for either the `previousKeyframe` or `nextKeyframe` which are both set within [KSA](https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments)

## #HotIf `WinActive(Premiere Pro)`
*The below hotkeys only activate while Adobe Premiere Pro is the active window.*

## `premzoomoutHotkey`
Sends the hotkey for `zoomOut` which is set within [KSA](https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments)

## `premselecttoolHotkey`
While you're editing text, getting back to the selection tool by pressing (in my case) `v` would just type `v` in the text box. This hotkey will attempt to warp to and press the selection tool instead. If that fails, it will focus the tool hotbar and then input `v` instead.

## `premprojectHotkey`
*This hotkey is highly specific to my Premiere window layout - picture below. It also contains a hardcoded reference to my sfx folder*

Premiere has a terrible habit of not saving where you want the `project` window to be in your workspace. This hotkey aims to move it into the correct posistion.

While this hotkey might appear as only one, it's actually 3 in 1.
At the time of writing the hotkey was `RAlt & p::`, the rest of this description will be based off that.

* If the user simply presses `RAlt & p::`

The hotkey will search for the `project` window. It will then grab it and drag it into the correct position. It will then open up my `sfx` directory and drag it into the project. Once that has finished getting added to the project, the macro will double click on the sfx folder within premiere to open it as a separate bin, it will then drag that bin under the project window to split them in half vertically.

* If the user holds `Ctrl` then presses and releases `RAlt & p` THEN releases `Ctrl`

When you reopen a project in premiere, sometimes the separate `sfx` bin won't be open anymore. This part of the hotkey will just reopen it as a separate bin and move it back into position.

* If the user holds `RShift` then presses and releases `RAlt & p` THEN releases `RShift`

When you reopen a project in premiere, sometimes the `project` window will just move itself back to whatever premiere deems as defaul. This part of the hotkey will just locate it and drag it back into position.

[img1 - 'default' premiere places things]
![prem1](https://user-images.githubusercontent.com/53557479/198946232-68a77117-3106-42c5-9fcd-f4eb5f9f945a.png)

[img2 - After holding `RShift` then pressing and releasing `RAlt & p` THEN releasing `RShift`]
![prem2](https://user-images.githubusercontent.com/53557479/198946367-4ea6cfc9-6841-43cb-a653-b7a6652bd3af.png)

[img3 - After holding `Ctrl` then pressing and releasing `RAlt & p` THEN releasing `Ctrl`]
![prem3](https://user-images.githubusercontent.com/53557479/198946513-6cb3be1b-e533-4303-9401-e35135e4a99a.png)
***

# Mouse Scripts

## `previouseditHotkey` & `nexteditHotkey`
run: [`wheelEditPoint()`](https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#wheeleditpoint) with their respective directions which is set within [KSA](https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments).

## `playstopHotkey`
Sends the hotkey `playStop` (which is set within [KSA](https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments)) to stop playback on the timeline. I have this bound to a button on my mouse.

## `nudgeupHotkey` & `nudgedownHotkey`
Send hotkeys relating to their respective direction to nudge tracks on the timeline. Hotkeys are set within [KSA](https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments).

## `slowDownHotkey` & `speedUpHotkey`
Send hotkeys relating to the respect speed change, to speed up or slow down playback on the timeline. Hotkeys are set within [KSA](https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments).

## `mousedragHotkey`
runs: [`mousedrag()`](https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#mousedrag)

## `bonkHotkey` & `bleepHotkey`
runs: [`audioDrag()`](https://github.com/Tomshiii/ahk/wiki/Adobe-Functions#audiodrag) with the respective audiofile name passed as the variable.
***

## Other - NOT an editor

## #HotIf `not WinActive("ahk_group Editors")`
*The below hotkeys only activate while a window in the group `Editors` is NOT the active window.*

## `winHotkeys`
runs: [`moveWin()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#movewin) with the respective hotkeys passed in as the variable to manipulate windows with just my mouse.

## `alwaysontopHotkey`
Toggles `AlwaysOnTop` for the active window

## `searchgoogleHotkey`
Searches the highlighted text in google.

## `capitaliseHotkey`
Will attempt to determine whether to completely capilitilse or lowercase the highlighted text depending on which is more frequent.

## `timeHotkey`
Will send `A_YYYY "-" A_MM "-" A_DD`

## `wheelupHotkey` & `wheeldownHotkey`
runs: [`fastWheel()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#fastwheel) to speed up scrolling.

## `youskipbackHotkey` & `youskipforHotkey`
runs: [`youMouse()`](https://github.com/Tomshiii/ahk/wiki/Windows-Functions#youmouse) with the respective hotkeys passed in as the variables to skip ahead/back in youtube.