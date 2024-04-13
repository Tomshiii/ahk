# <> Release 2.14.2 - Rudimentary NVENC Support
> [!Note]
> Support for NVNEC across my scripts is not universal, only the main scripts get its addition. Some other scripts (ie. the crop scripts) will no be receiving these changes (at least in this release)

## > Functions
- Fixed `startup.adobeTemp()` failing to delete anything
- Added `Win32_VideoController()` by `jNizM` to get information about the user's GPU
- Added `useNVENC()` to rudimentarily determine whether the user can use NVENC encoding
- Reverted `winget.ProjPath()` using `PremiereRemote` to retrieve the current project path as it causes the function to silently throw in the event that `Premiere` isn't currently responding

`ffmpeg {`
- Fixed `__getFrequency()` not correctly determining the amount of audio tracks
- `reencode_h26x()` now has rudimentary `nvenc` support
    - `reencodeGUI` will now also offer basic GPU rendering options

`prem {`
- Fixed `Previews()` failing to make a save attempt if the user wasn't using `PremiereRemote`
- Fixed `zoomPreviewWindow()` stopping the user from using <kbd>!</kbd>, <kbd>@</kbd> or <kbd>#</kbd> while the project window was active or while interacting with a different GUI within Premiere (ie. naming a nested sequence)
- Added `saveAndFocusTimeline()` to cut repeat code
    - `render and replace.ahk` now uses this code to lower the frequence of sequences being cycled

`premUIA_Values {`
- Will now additionally set the `project window`
- Will now alert the user if a value hasn't been set (ie. if they update the script without setting new values)

## > Streamdeck AHK
- `lock` scripts now allow the user to select a range of tracks to toggle by first pressing `NumpadDiv`
    - Each selection will either wait for two numbers to be pressed or for the user to press <kbd>NumpadEnter</kbd> between each selection

`download` scripts
- Now include `--verbose` to give a more detailed output to the commandline
- Now do a rudimentary check for `NVENC` and will render using it if available

## > Other changes

`autosave.ahk`
- Fixed script failing to make a save attempt if the user wasn't using `PremiereRemote`
- Identified an occurrence of the script silently crashing in the background, causing <kbd>ctrl + s</kbd> to no longer work