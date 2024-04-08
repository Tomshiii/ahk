# <> Release 2.14.x - 

## > Functions
- Fixed `prem.Previews()` failing to make a save attempt if the user wasn't using `PremiereRemote`
- Fixed `startup.adobeTemp()` failing to delete anything
- Reverted `winget.ProjPath()` using `PremiereRemote` to retrieve the current project path as it causes the function to silently throw in the event that `Premiere` isn't currently responding

## > Other changes
- Fixed `autosave.ahk` failing to make a save attempt if the user wasn't using `PremiereRemote`