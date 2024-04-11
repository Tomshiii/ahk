# <> Release 2.14.x - 

## > Functions
- Fixed `startup.adobeTemp()` failing to delete anything
- Fixed `ffmpeg.__getFrequency()` not correctly determining the amount of audio tracks
- Reverted `winget.ProjPath()` using `PremiereRemote` to retrieve the current project path as it causes the function to silently throw in the event that `Premiere` isn't currently responding

`prem {`
- Fixed `Previews()` failing to make a save attempt if the user wasn't using `PremiereRemote`
- Fixed `zoomPreviewWindow()` stopping the user from using <kbd>!</kbd>, <kbd>@</kbd> or <kbd>#</kbd> while the project window was active or while interacting with a different GUI within Premiere (ie. naming a nested sequence)
- Added `saveAndFocusTimeline()` to cut repeat code
    - `render and replace.ahk` now uses this code to lower the frequence of sequences being cycled

`premUIA_Values {`
- Will now additionally set the `project window`
- Will now alert the user if a value hasn't been set (ie. if they update the script without setting new values)

## > Other changes
- `download` Streamdeck scripts now include `--verbose` to give a more detailed output to the commandline

`autosave.ahk`
- Fixed script failing to make a save attempt if the user wasn't using `PremiereRemote`
- Identified an occurrence of the script silently crashing in the background, causing <kbd>Ctrl + s</kbd> to no longer work