_**You do not need to run this script, it gets `#Include(d)` in `Functions.ahk` which then gets `#Include(d)` in `My Scripts.ahk`**_

`Keyboard Shortcut Adjustments` is to bring quick and easy support to adjust keyboard shortcuts within scripts without needing to dig into the code of each individual function or macro.

With the addition of [`[Keyboard Shortcuts.ini]`](https://github.com/Tomshiii/ahk/blob/main/KSA/Keyboard%20Shortcuts.ini) you are able to quickly go in and adjust any keyboard shortcut and have it instantly reflect within any scripts that use it.

Alongside this .ini file is the companion [`[Keyboard Shortcut Adjustments.ahk]`](https://github.com/Tomshiii/ahk/blob/main/KSA/Keyboard%20Shortcut%20Adjustments.ahk) file which is where we create the values we then later call from within scripts.

So first we define the hotkey within the `Keyboard Shortcuts.ini` file
```autohotkey
[Premiere]
Effect Controls="^+4"
;[effectControls] (easy searching)
```
Then within the `Keyboard Shortcut Adjustments.ahk` file you'll see;
```autohotkey
location := `A_WorkingDir` ;this directory should automatically be replaced by `locationReplace()`

effectControls := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Effect Controls")
```
which we can then call in other scripts like;
```autohotkey
#Include "%A_ScriptDir%\KSA\Keyboard Shortcut Adjustments.ahk"
hotkey::
{
    SendInput(effectControls)
}
```