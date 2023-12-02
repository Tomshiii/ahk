Hi there! welcome to Tomshi's ahk scripts! (`..\` stands for the root directory of my repo that you just extracted!)

If this is your first time downloading my scripts and you just ran the `.exe` file in a location you don't want it to be no worries! Just move the release `.exe` wherever you wish and then run it again to extract my repo in the proper destination!

After running the release `.exe` you will be prompted with a GUI to select a few options on install:
___

**Symlink:**

Will create a symlink between ``A_MyDocuments \AutoHotkey\`` & the ``..\lib\`` folder in these scripts. This symlink is essential for correct opperation but only needs to be created once (or if the user moves the repo to a new directory.)  
> *This means that if you download a **new** release and don't put it in the same file directory, the symlink will need to be regenerated.*  

This script will also generate some symlink folders within ``..\Support Files\ImageSearch\(AE/Premiere)`` to partially support more versions.  
> *These folders being generated does not mean those versions are completely compatible with my scripts. I do not have the time or man power to support versions that I do not use. The version I'm currently using will be listed at the top of the class file fould in ``..\lib\Classes\Editors\(After Effects.ahk/Premiere.ahk)``*

#### note: selecting this option will ask for elevation, this is necessary as cmd needs to be elevated to create symlinks. This option should *not* be selected if the current directory is *not* the final destination for this repo
___

**Hotkey Replacer:**

Will produce a GUI that will allow the user to replace any hotkeys (in `My Scripts.ahk`) and KSA.ini values in this release with their own.

A backup of the original release versions of `My Scripts.ahk` & `Keyboard Shortcuts.ini` will be saved in `\Backups\` just incase something goes wrong.

**note: selecting this option is only necessary if the user has an older version of my scripts already in use*

___

**Run at Startup:**

Will create a shortcut of `PC Startup.ahk` (`..\PC Startup\PC Startup.ahk`) in the user's startup folder `C:\Users\A_UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`. This can be disabled/reenabled later in `settingsGUI()` (`#F1` by default)

___

**adobeKSA:**

Is a script that allows the user to parse their individual `Premere Pro` & `After Effects` keyboard shortcuts files and attempt to map those shortcuts to respective `KSA` variables within this repo. This script is not perfect and it is recommended to backup any old `KSA.ini` files in use if attempting to use this script.

___

If you choose to ignore this install step and wish to run these files at a later time, they can be located;  
Symlink:            `..\Support Files\Release Assets\CreateSymLink.ahk`  
Hotkey Replacer:    `..\Support Files\Release Assets\HotkeyReplacer.ahk`  
PC Startup:         `..\PC Startup\PC Startup.ahk`  

Windows Defender might have a red hot complain about the `v2.x-.exe` file (even after you've used it) and attempt to remove it. It's a compiled copy of my scripts (basically the same as downloading the repo off github), alongside the `SevenZip.ahk` lib by `thqby` to allow me to include the repo in a .zip file that then gets automatically extracted when you run the release `.exe` you can see how this process works by looking at `..\Support Files\Release Assets\generateUpdate.ahk` in the repo ^.^

If your installer fails, a `settings.ini` file may fail to generate in `A_MyDocuments\tomshi\`. If this happens you can try running `baselineSettings.ahk` found: `..\Support Files\Release Assets\baselineSettings.ahk` to get started.

⠀⠀⠀⠀⠀⠀⢀⣤⣚⣛⡶⣒⡁⠐⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡾⠃⣀⠈⠉⡀⠈⠳⡀⠘⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⠃⢸⣿⠀⣼⡇⠀⠀⢣⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣀⠤⠖⠚⠒⠺⢧⡀⠙⠁⠀⠀⡜⠀⠀⠣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢀⠞⢣⠀⡠⠄⠀⠀⠀⠈⠦⠤⠤⠊⠀⠀⠀⠀⠈⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀⠀⠀⠀
⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⣰⠃⠀⠀⠀⠀⠀⠀⠀⠀
⠸⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠞⠦⠀⠀⠀⣀⢼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠈⠓⠤⢄⣀⣀⣀⡀⠤⠒⠁⠀⣀⠔⡶⠻⢥⠼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠁⠒⢒⠏⠈⠉⠀⠀⢷⠤⠮⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⠀⠀⠀⢀⠀⢈⢆⣀⣼⡒⠒⠲⢤⣀⠀⣠⠔⢆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠈⢧⠀⠙⢜⣆⠑⣄⠀⠀⠈⡝⡄⠀⠈⡄
⠀⠀⠀⠀⠀⠀⠀⢰⠋⢃⠀⠀⢀⡀⠬⠂⠀⠈⡏⢦⡀⠑⠢⠔⠁⡸⠀⢀⠁
⠀⠀⠀⠀⠀⠀⢀⠼⠤⢸⡄⠀⡏⠀⠀⠀⠀⠰⡁⠀⠉⠒⠒⠒⠈⠀⠀⡸⠀
⠀⠀⠀⠀⠀⠀⠈⢇⣀⡀⠘⣦⡞⠀⠀⠀⠀⢠⠟⠀⠀⠀⠀⠀⠠⠀⡰⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⡩⠭⠤⠿⣲⢖⣒⠚⢫⣀⣀⣀⣀⡀⢀⡧⠊⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⠉⠀⠀⠀⠀⠈⡠⠤⠛⠛⠦⡀⠀⠀⠈⣹⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠘⣄⠀⠀⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⡆⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠸⡉⠒⠒⠒⠳⣄⠀⠀⠀⠀⠀⠀⠀⢀⣠⠃⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⢧⣈⣉⣀⣈⣉⠭⠝⠒⠊⠀⠀⠀⠀⠀