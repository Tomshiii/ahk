`Keyboard Shortcut Adjustments` is a `.ini`/`.ahk` combo to bring quick and easy support to adjust keyboard shortcuts within scripts without needing to dig into the code of each individual function or macro.

With the addition of [`[Keyboard Shortcuts.ini]`](https://github.com/Tomshiii/ahk/blob/main/lib/KSA/Keyboard%20Shortcuts.ini) you are able to quickly go in and adjust any keyboard shortcut and have it instantly reflect within any scripts that use it.

Alongside the .ini file is the companion [`[Keyboard Shortcut Adjustments.ahk]`](https://github.com/Tomshiii/ahk/blob/main/lib/KSA/Keyboard%20Shortcut%20Adjustments.ahk) file which is where we create the variables we then later call from within scripts.

So first we define the hotkey within the `Keyboard Shortcuts.ini` file
```autohotkey
[Premiere]
effectControls="^+4"
;[effectControls] ;Within Premiere - [(Application > Window >) Effect Controls]
```
Then within the `Keyboard Shortcut Adjustments.ahk` we automatically generate `effectControls` as a variable that can be called like so;
```autoit
#Include <KSA\Keyboard Shortcut Adjustments>
hotkey::
{
    ...
    SendInput(KSA.effectControls)
    ...
}
```
***

## Some important things to note:
- Any custom keyboard shortcuts you add here WILL NOT get automatically added to future releases and will need to be manually transferred over BUT any changes you make to existing hotkeys will
- If you change any of these values, do note: because these values are only assigned to variables during runtime, you will need to reload any script that calls the value you have changed
- DO NOT PUT THE FOLLOWING IN A KEY OR VALUE; `=`, \`n, \`r, `"`  
#### USING ANY OF THE ABOVE WILL BREAK KSA  
- All non integer values should be encased in `""` NOT `''` this is important for `KSA.ahk` to work correctly
- Any variable names (ini key values) that contain spaces will have them replaced with `_`
    - eg: `scale framesize="xyz"` becomes: `KSA.scale_framesize`