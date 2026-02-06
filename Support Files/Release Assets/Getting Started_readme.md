Hi there! welcome to Tomshi's ahk scripts! (`..\` stands for the root directory of my repo that you just extracted!)

If this is your first time downloading my scripts and you just ran the `.exe` file in a location you don't want it to be no worries! Just move the release `.exe` wherever you wish and then run it again to extract my repo in the proper destination!

After running the release `.exe` you will be prompted with a GUI to select a few options on install:

___

**Run at Startup:**

Will create a shortcut of `Initialise.ahk` (`..\PC Startup\Initialise.ahk`) in the user's startup folder `C:\Users\A_UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`. This can be disabled/reenabled later in `settingsGUI()` (`#F1` by default)

___

**adobeKSA:**

Is a script that allows the user to parse their individual `Premere Pro` & `After Effects` keyboard shortcuts files and attempt to map those shortcuts to respective `KSA` variables within this repo. This script is not perfect and it is recommended to backup any old `KSA.ini` files in use if attempting to use this script.

___

If you choose to ignore this install step and wish to run these files at a later time, they can be located;  
Hotkey Replacer:    `..\Support Files\Release Assets\HotkeyReplacer.ahk`  
PC Startup:         `..\PC Startup\Initialise.ahk`  

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