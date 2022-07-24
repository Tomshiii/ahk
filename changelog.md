# <> Release 2.4.2.x

# > Functions
- `updateChecker()` will now attempt to download `.exe` release first, if not found will attempt a `.zip` and if that fails inform the user and back out. This is to replace the old behaviour of just downloading a dud file

`locationReplace()` 
- Will no longer show tooltips everytime it's run if the user's working dir isn't my preset one
    - Will now show `TrayTip`'s to alert the user when it is beginning/when it has finished attempting to change location variables
- Will no longer crossreference my particular install location and will instead take note of the current install location of the scripts, store the working directory in `A_MyDocuments \tomshi\location` and will crossreference that file each time at startup. If at any point the scripts are moved, simply rerunning `My Scripts.ahk` will trigger `locationReplace()` to fire again and replace all required path instances