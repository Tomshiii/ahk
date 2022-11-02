A list of `switchTo` Functions complete with definitions.

The idea behind these functions was initially showcased by [Taran](https://github.com/TaranVH/2nd-keyboard) a previous editor for LTT.

Their main purpose is to;

* If an instance of the desired program doesn't exist, open it
* If an instance of the desired program DOES exist, activate it
* If multiple instances of the desired program exists, cycle between them based off the last active

A list of `switchTo` scripts based off this premise includes;

* `switchToExplorer()`
* `switchToPremiere()`
* `switchToAE()`
* `switchToDisc()`
    * I have this function move my discord window to a specific position if it's not already. Check that position at the top of the script
* `switchToPhoto()`
* `switchToFirefox()`
* `switchToOtherFirefoxWindow()`
    * I use this in other functions for various reasons
* `switchToVSC()`
* `switchToStreamdeck()`
* `switchToExcel()`
* `switchToWord()`
* `switchToWindowSpy()`
* `switchToEdge()`
* `switchToMusic()`
***

# Other scripts in this file include

## `closeOtherWindow()`
This function when called will close all windows of the desired program EXCEPT the active one. Helpful when you accidentally have way too many windows open.
```
closeOtherWindow( [program] )
```
#### program
Type: String - Program Information
> Either `ahk_exe program.exe` or a `ahk_class x` of the desired program.
