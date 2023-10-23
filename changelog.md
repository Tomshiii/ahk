# <> Release 2.13.0 - 
- `Keyboard Shortcuts.ini` has been moved from `..\lib\KSA\` => `..\Support Files\KSA\`
    - This should allow the user to more easily, manually update their entire `..\lib\` folder without worrying about `KSA.ini` getting wiped in the process
> ##### *It should be noted that this change does not protect the user in the event that a new `KSA` variable is added. It will need to be manually added back by the user or they will have to go through the usual update steps.*
- `dirs.ini` has been added to `..\Support Files\Streamdeck Files\` where all directories specific to `Streamdeck AHK` will be kept
    - This should allow the user to more easily, manually update their entire `..\Streamdeck AHK` folder without worrying that any custom directories set are going to be wiped

## > Functions
- Added `editScript()`
- Fixed `ytdlp().handleDownload()` not handling outlier scenario where a `.mkv` is generated
- Removed references to `7zip.ahk` from `startup.libUpdateCheck()` as the script has been pulled by `thqby`
- `rbuttonPrem().movePlayhead()` now accepts optional param `allChecks` and allows the user to call `movePlayhead()` even if the cursor is hovering over a video/audio track
- `checkStuck()` now accepts optional param `arr` to pass in a custom array of buttons to check
- `errorLog()` will now check for, and strip the `err.what` string of the passed in error object of the word `Prototype.` to make resulting logs easier to read
- Code taken from `settingsGUI()` to add `generateAdobeShortcut()`
- `getHTML()` will now check the resulting string for error messages
- `mouseDrag()` will now delay slightly between inputs to reduce the number of times the function is too fast for the desired input
- `encodeGUI {` now offers the option of setting a `bitrate` value instead of a `crf` value
- `ffmpeg.reencode_h26x()` now accepts parameter `bitrate` if the user wishes to define a bitrate value instead of a `crf` value. Note: only one can be used at a time and the other **must** be set to false

`startup {`
- `adobeTemp()` will no longer run if `Premiere` or `After Effects` is currently open
- `trayMen()` now offers option to open `Premiere_UIA.ahk`

`switchTo`
- `Premiere()` & `AE()` will now;
    - Check for the existence of `Creative Cloud` and attempt to open it before proceeding
        - Both functions now also accept parameter `openCC` to determine if this behaviour is desired. It is set to `true` by default
    - Attempt to generate a shortcut (using values set within `settingsGUI()`) if one isn't detected

## > hCrop
Added a series of scripts designed to split a video in half along the horizontal axis
- Added `hCropGui.ahk`      - to extend off `encodeGUI {` and provide a few more options for some of the below scripts
- Added `hCropLoop.ahk`     - to split in half all `.mkv` files in a directory and output to two new files
- Added `hCrop OnlyCam.ahk` - to produce a GUI allowing the user to select only one half of all `.mkv` files in a selected directory to be output to a new file
- Added `hCrop Single.ahk`  - to split in half a single selected file

## > Other Changes
- `autosave.ahk` will no longer backup project files when the user manually saves with <kbd>Ctrl + s</kbd> to help mitigate the backup folders inflating to giant sizes during long projects
- Added `v24` Premiere template
- Added `nameof.ahk` by `thqby`
- Added `deleteDotUnderscore.ahk` to delete annoying macOS files from a directory
- Added `audSelect.ahk` & `vidSelect.ahk` as additional `..\Streamdeck AHK\download\` scripts to offer the same functionality but the user gets to decide the final file destination before the script begins
- Fixed `Move Project.ahk` throwing when it attempts to delete a `Backups` folder
- Fixed `tiktok project.ahk` not using the selected resoltion
- Updated UIA lib