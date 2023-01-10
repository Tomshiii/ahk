# <> Release 2.9.x - 
- Fix installation process failing due to `settings.ini` file not existing yet
    - Added `baseLineSettings.ahk` to `..\Support Files\Release Assets\` to quickly genereate a baseline `settings.ini` file in the event that the installation process fails
- More checks during the installation process to ensure the extraction has actually taken place before deleting files

## > Functions
- Fix `startup.adobeTemp()` causing errors if the directory doesn't exist
- `checkInternet()` now does more than simply checking if the user is connected to a network
- `detect()` now returns the original values as an object
- `prem.movepreview()` now has more fallback in the event it can't find the video you're looking to move

`disc.button()`
- Update images
- Fix cursor returning to incorrect position on failure

`WinGet`
- Added `winget.WinMonitor()`
- Fixed `winget.Title()` error causing a throw