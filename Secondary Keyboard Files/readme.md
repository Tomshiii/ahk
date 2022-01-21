###### **_it is not recommended to use these files on your own keyboard as that could in a best case scenario do nothing, but in a worst case break something. Do not flash these to your own board unless you know exactly what you're about to do, these files are here for my own backups and to provide credit for the contributions made by JivanYatra_**

# Info
This folder contains all the files necessary to allow ***my*** secondary keyboard (Planck EZ Glow) to work alongside my main keyboard without stepping on its toes by wrapping each keystroke in an `F24` keystroke. This allows me to differentiate between the two keyboards with ahk.
###### **_these firmware files are incomplete but functional currently_**

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

# Contributions & Credits
The files contained in this folder are the generous works of ***JivanYatra*** and without their kindness and help, I would still be stuck on a tiny little numpad. Huge thank you to them for all of their hard work as well as all the code and custom firmware to make it all happen.

### Their github: > https://github.com/jivanyatra