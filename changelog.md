# <> Release 2.8.x -
Congratulations to ahk for `v2.0.0` hitting a full release! 🎉🎉

All scripts have been updated to require `v2.0` as a minimum!

## > Functions
- Added `getHTMLTitle.ahk` to return the title of a passed url
- Added `ae.wiggle()`
- Added `startup.monitorAlert()` which will log the user's monitor setup and check for any changes so the user can be alerted as scripts may break due to changed pixel coordinates
- Fixed `getHTML.ahk` not including proper `#Includes`
- Added `openSocials()` to open the youtube/twitch of the current project client
    - Added `openYoutube.ahk` & `openTwitch.ahk` as streamdeck scripts
- `getHotkeys()` `VarRefs` are now optional
    - Also now returns an object
- If `reload_reset_exit()` fails to reload, it will now read a registry value set during the ahk install process that contains the users default editor. If this value is for some reason **not** set, the function will default to VSCode before futher falling back to asking the user to select a new default editor.
- `errorLog()` will now additionally send the error to `OutputDebug()`

`fastWheel()`
- Will now check for the state of `LButton` to allow for bulk highlighting
- Will now only attempt to send the `focusCode` hotkey once every `5s` instead of every activation.

`updateAHK()`
- Now offers the user the ability to run the installer after download
- Now uses the `_DLFile.ahk` lib so the user knows a download is taking place

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

> `.PremName()/.AEName()`
- 2nd and 3rd `VarRefs` are now optional and no longer required
- All return paths that indicate an error/fail now pass back `false` so `if !winget.PremName()` works as expected

## > My Scripts
- Added a hotkey to disable `Tab` in `Premiere`
- Added a hotkey to return `Ctrl + BackSpace` functionality to `Premiere` as adobe doesn't let you do so
- Added a hotkey to make `+*` remap to `^i` in `Discord`
- Added hotkeys to quickly move `12 frames` in either direction in `Premiere`
- `AppsKey:: ;akhdocuHotkey;` will now attempt to pull up the local documentation before falling back to the online documentation
- `SC03A & v:: ;premselecttoolHotkey;` will now activate the `program monitor` after the activating selection tool

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
- `prem.mouseDrag()` & `right click premiere` no longer stop each other with their tooltips
- `CreateSymLink.ahk` now attempts to backup the lib folder if it already exists

`autosave.ahk`
- Will now check if `Premiere/AE` is not responding and will reset the timer if true
- Will now check to ensure that `{RButton}` & `\` aren't being held down before performing a save attempt