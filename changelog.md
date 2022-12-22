# <> Release 2.8.x -
Congratulations to ahk for `v2.0.0` hitting a full release! 🎉🎉

All scripts have been updated to require `v2.0` as a minimum!

## > Functions
- Added `getHTMLTitle.ahk` to return the title of a passed url
- Fixed `getHTML.ahk` not including proper `#Includes`
- `fastWheel()` will now check for the state of `LButton` to allow for bulk highlighting
- `getHotkeys()` `VarRefs` are now optional

`resolve {`

Cleaned up the entire class.

- Cut a lot of repeat code by feeding it through a function
- Removed KSA values relating to `ImageSearch` coordinates and replaced with class objects containing coordinates

`prem {`
- `prem.zoom()` will no longer produce multiple tooltips to alert the user that toggles are being reset
- `preset()` will now loop attempting to get the `classNN` value in an attempt to fix it constantly failing

`winget {`
- Added `ProjClient()` to retrieve the name of the client the current project is for by stripping the directory path in the title
    - `prem.zoom()` now uses `winget.ProjClient()` and references that value instead of hard coding for every client

`.PremName()/.AEName()`
- 2nd and 3rd `VarRefs` are now optional and no longer required
- All return paths that indicate an error/fail now pass back `false` so `if !winget.PremName()` works as expected

## > My Scripts
- Added a hotkey to disable `Tab` in `Premiere`
- Added a hotkey to return `Ctrl + BackSpace` to `Premiere` as adobe doesn't let you do so
- `AppsKey:: ;akhdocuHotkey;` will now attempt to pull up the local documentation before falling back to the online documentation

## > Streamdeck AHK
- `New Premiere.ahk` now copies a template `.prproj` file instead of manually creating one
- Added `thumbnail.ahk` that uses `ytDownload()` to download a videos thumbnail
- Moved `speed` & `scale` scripts into their own folders
    - `scale` scripts now work in `Resolve` as well as `Premiere`

`ytDownload()`
- Fixed bug relating to incorrect filepath variable
- Fixed bug causing function to activate premiere instead of explorer
- Fixed bug causing download to fail if attempting to set the download url from the old clipboard
- Will now automatically convert downloaded mkv to mp4 files using `convert2`
    - Changed args for `video.ahk` and `vfx.ahk`

## > Other Changes
- `autosave.ahk` will now check if `Premiere/AE` is not responding and will reset the timer if true
- `prem.mouseDrag()` & `right click premiere` no longer stop each other with their tooltip