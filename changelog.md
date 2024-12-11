# <> Release 2.15.1 - Bugfix & Improvements

## Functions
- Fixed `generateAdobeShortcut()` not properly generating `Photoshop` shortcuts
- `rbuttonPrem().movePlayhead()` will no longer input a bunch of characters if the user is typing when activated
- `switchTo.adobeProject()` should now move any windows it incorrectly activates to the bottom of the stack

`prem {`
- Added `layerSizeAdjust()`
- Added `toggleLayerButtons()`

`startup {`
- `adobeVerOverride()` will now show if you have the beta version selected during the `notify`
- `updatePackages()` will no longer alert the user if only `ignored` updates exist
> [!Note]
> This feature is currently only available if `choco` is the selected package manager

## Other Changes
- Updated use of `notify {` across scripts to make them more consistent
- Updated some `After Effects` ImageSearch images for `v25.1` & `v25.2`
- `Always Check UIA` will now default to `true` during new installs