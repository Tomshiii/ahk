# <> Release 2.12.x - 

## > Functions
- Fix `rbuttonPrem {` throwing while attempting to access a property that didn't exist
- Fix `Premiere_UIA.ahk` throwing if the specific version set within `settingsGUI()` doesn't have a corresponding class (*ie. if the user updates their version of `Premiere` and doesn't set the new version*)
    - The script will now have a `base` class for each main release and then if any individual version causes breaking changes, a new class can be created that extends off the base
- Pulled code out of `gameCheck.ahk` to create `WinGet.isProc()` that checks to see if a window is a common `windows explorer` element that you may want another piece of code to ignore
- Pulled `drawBorder()` out of `alwaysOnTop()` and placed in its own function

## > Other Changes
- Update `adobeVers.ahk`