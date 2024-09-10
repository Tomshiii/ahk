# <> Release 2.14.x - 

## Functions
- Updated AE `focusColour` variable for versions using the `Spectrum UI` to return functionality to functions that rely on it
- Fixed `adobeVers.__generate()` not generating symbolic links for beta versions if their year version is ahead of the current year

`ytdlp {`
- Fixed `download()` failing to increment filenames past `1`
- `download()` will now check the window filepath before reactivating it, ensuring it doesn't activate a random window simply because it shares the same folder name

## Other Changes
- Added `partDL.ahk` GUI for `vidPart.ahk` & `audPart.ahk` to more easily define their timecode ranges
- `autosave.ahk` will no longer cause a double save if the user manually saves Premiere while the timer is waiting for the user to go idle