# <> Release 2.8.x -
Congratulations to ahk for `v2.0.0` hitting a full release! 🎉🎉

All scripts have been updated to require `v2.0` as a minimum!

## > Functions
- Added `getHTMLTitle.ahk` to return the title of a passed html object
- Fixed `getHTML.ahk` not including proper `#Includes`
- `fastWheel()` will now check for the state of `LButton` to allow for bulk highlighting
- `prem.zoom()` now uses `winget.ProjClient()` and references that value instead of hard coding for every client

`winget {`
- Added `ProjClient()` to retrieve the name of the client the current project is for by stripping the directory path in the title

`PremName()/AEName()`
- 2nd and 3rd `VarRefs` are now optional and no longer required
- All return paths that indicate an error/fail now pass back `false` so `if !winget.PremName()` works as expected

## > Streamdeck AHK
- `New Premiere.ahk` now copies a template `.prproj` file instead of manually creating one

`ytDownload()`
- Fix bug relating to incorrect filepath variable
- Fix function activating premiere instead of explorer
- Will now automatically convert downloaded mkv to mp4 files using `convert2`
    - Changed args for `video.ahk` and `vfx.ahk`

## > Other Changes
- `autosave.ahk` will now check if `Premiere/AE` is not responding and will reset the timer if true