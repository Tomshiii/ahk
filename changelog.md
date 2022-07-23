# <> Release 2.4.2.x

# > Functions
- `updateChecker()` will now attempt to download `.exe` release first, if not found will attempt a `.zip` and if that fails inform the user and back out. This is to replace the old behaviour of just downloading a dud file

`locationReplace()` 
- Will no longer show tooltips everytime it's run if the user's working dir isn't my preset one
- Will now show `TrayTip`'s to alert the user when it is beginning/when it has finished attempting to change location variables