# <> Release 2.15.x - 

## Functions
- Fixed `generateAdobeShortcut()` not properly generating `Photoshop` shortcuts
- `rbuttonPrem().movePlayhead()` will no longer input a bunch of characters if the user is typing when activated

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
- `Always Check UIA` will now default to true during new installs