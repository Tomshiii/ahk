# ahk

This is a combination of all the scripts I use almost daily to help with either making content (videos or streaming related), or just speeding up mundane random interactions with a computer.

Included is also the Excel document I use to keep track of any hotkeys I set, just as an easier and more visual way of understanding what is/isn't available.

A lot of the code in My Scripts.ahk is either inspired by, or taken from Taran from LTT (https://github.com/TaranVH/). His videos on ahk got me into fiddling around with it myself so many thanks.

You can watch me use some of these scripts in action while I edit away on  twitch when I stream on my bot account: https://www.twitch.tv/botshiii

## Currently WIP:
- [X] My Scripts.ahk
- [X] scripts f keys taken.xlsx
- [x] Porting Scripts to [AHK v2.0](https://github.com/Tomshiii/ahk/tree/v2.0)
- [ ] Resolve_Example.ahk (port over functionality occasionally)
- [ ] fkey auto launch (not often)

## What to do:
1. Download and install [AHK](https://www.autohotkey.com/)
2. Download and install either; (You could technically just edit scripts in notepad if you really wanted to, but I honestly don't recommend it)
   - [Notepad++](https://notepad-plus-plus.org/downloads/)
     - Then download and install the [ahk language for notepad++](https://www.autohotkey.com/boards/viewtopic.php?t=50)
   - [VSCode](https://code.visualstudio.com/)
     - Then install an AHK extension within the program for a more complete package.
3. Edit and then run any of the .ahk files to then use to your liking!
   - Scripts that will work with no tinkering include ->
     - Alt Menu acceleration disabler
     - autodismiss error
     - fkey auto launch (recommended you check it out first though as it opens specific programs)

Any scripts that contain pixel coordinates rely not only on my monitor layout, but also my workspace layout within premiere and will not necessarily work out of the box. They will require looking at the individual comments to get an idea of what is going on, then adjusting accordingly using Window Spy which gets installed alongside AHK

## Explanation:
Item | Use
------------ | -------------
My Scripts.ahk | My main scripts, contains everything I use for stream and editing, as well as a few windows related things I do to speed a few interactions up.
Resolve_Example.ahk | An example script for Davinci Resolve that has ported a few things from my premiere scripts to help you get started. This is very rough and thrown together.
fkey auto launch.ahk | A script from [Taran](https://github.com/TaranVH/) to auto launch OR swap to specific applications if they're already open
Alt_menu_acceleration_DISABLER.ahk | A script from [Taran](https://github.com/TaranVH/) to disable the alt menu acceloration unless you _hold_ down the alt key
autodismiss error.ahk | A script from [Taran](https://github.com/TaranVH/) to remove an annoying dialogue box in premiere that treats you like a child
right click premiere.ahk | A script from [Taran](https://github.com/TaranVH/) to move the playhead in premiere with the right mouse button
scripts f keys taken.xlsx | An Excel doc I use to track all the button combinations used in my scripts so I know what is/isn't available.

## Version Information:
These scripts are all currently for v1.1 of AutoHotkey. From my testing most of them will not work in the upcoming v2.0 without heavy modification. I'm not exactly much of a coder so trying to port over a lot of functionality into said newer version is definitely leaving me scratching my head but the hope is to one day do that(?). Until then, scripts that work in [v2.0](https://github.com/Tomshiii/ahk/tree/v2.0) (with updated files) include:
- [ ] My Scripts.ahk
- [x] fkey auto launch.ahk
- [x] Resolve_Example.ahk
- [x] Alt_menu_acceleration_disabler.ahk
- [ ] autodismiss error.ahk
- [x] right click premiere.ahk