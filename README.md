# ahk
## Version Information:
This repo is to work on v2.0 functionality to my scripts. I'm not exactly much of a coder so trying to port over a lot of functionality into said newer version definitely had me scratching my head but I believe I've mostly done it. The scripts that work in v2.0 include:
- [x] My Scripts.ahk
- [x] fkey auto launch.ahk
- [x] Resolve_Example.ahk
- [x] Alt_menu_acceleration_disabler.ahk
- [x] autodismiss error.ahk
- [x] right click premiere.ahk

## What to do:
1. Download and install [AHK v2.0 Beta](https://www.autohotkey.com/)
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
