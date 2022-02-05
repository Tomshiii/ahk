# <> Release 2.3.1 - Functions.ahk

This release lays the groundwork for a future installer file to work. In the future alongside raw versions of my script will be an installer ahk file that will replace my set hotkeys with your own custom set hotkeys (for `My Scripts.ahk`). By design, it will not work or be available for this version of the scripts, but will *hopefully* be functional and available by the next release.

## > ~~MS_functions~~ Functions
Most functions contained within the MS_functions.ahk file have now been split off into their own ahk files. This file was getting far too large for its own good and it makes sense to separate things out to keep easier track of it all. These new files can be found in the `\Functions` folder in the directory.

- [#1] Created `After Effects.ahk`, `Photoshop.ahk`, `Premiere.ahk`, `Resolve.ahk`, `switchTo.ahk` & `Windows.ahk` to separate out my functions into individual files. These are all then `Include(d)` into the main `Functions.ahk` file 
    - [#1] Renamed `MS_functions.ahk` -> `Functions.ahk`
- Removed the doubling up of code between `switchToMusic()` & `musicGUI()`
    - Adjusted the gui to remove the "default" button so nothing is highlighted when opened

## > My Scripts
- [#3] The Update checker has changed and will not function for this release but will moving forward
    - Update checker now warns the user before downloading the update that if changes have been made by the user, loss of data may occur if they override their scripts with the update folder
    - Update checker will also automatically attempt to backup the users script directory after downloading the latest update

### > Other Changes
- `move project.ahk` now deletes additional residual cache files in your project directory before moving your project
    - it also deletes the files in the `AppData\Media Cache Folder` when the size of the folder is larger than what is set within the code - `15gb by default`
- Added `obs_screenshot.ahk` to quickly activate and screenshot the obs preview window
- Increased the delay for `autosave.ahk` from 5min -> 7.5min
    - Made it easier to customise the amount of time between each save
- Fixed `qss_firefox` scripts so they grab screen coords originally so the mouse returns to the correct position
- Added `convert webm2mp3.ahk` to batch convert `webm` files to `mp3` using `ffmpeg` and `cmd`
    - Renamed `convert to mp4.ahk` -> `convert mkv2mp4.ahk` to fall inline with above
- Update readme