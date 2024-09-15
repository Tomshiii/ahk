# <> Release 2.14.x - 

## Functions
- Updated AE `focusColour` variable for versions using the `Spectrum UI` to return functionality to functions that rely on it
- Fixed `adobeVers.__generate()` not generating symbolic links for beta versions if their year version is ahead of the current year
- Added `prem.escFxMenu()` to automatically dismiss some FX menus that would otherwise require the user to manually dismiss them

`ytdlp {`

`download()`
- Fixed function failing to increment filenames past `1`
- Will now check the window filepath before reactivating it, ensuring it doesn't activate a random window simply because it shares the same folder name

## Other Changes
- `autodismiss error.ahk` now works with the `Spectrum UI`
- Added `partDL.ahk` GUI for `vidPart.ahk` & `audPart.ahk` to more easily define their timecode ranges
- `autosave.ahk` will no be less likely to cause a double save if the user manually saves Premiere while the timer is waiting for the user to go idle
- `enable unsigned extensions.ahk` is now a GUI that allows the user to select the versions they wish to enable extensions for
    - This GUI will also be presented to the user during `installPremRemote.ahk`