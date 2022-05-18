# <> Release 2.3.3.1 - 

## > Functions
- `disc()` now increases the `y` value it searches for buttons on each loop of ImageSearch as in some servers there will be many more options in the right click context menu depending on permissions the user has
- `wheelEditPoint()` now waits for the user to release the hotkey before being able to fire again

`vscode()`
- Updated `explorer.png` to fix for the latest versions of vscode/my theme
- Added `explorer2.png` as depending on which toolbar you're in, the icon shows signs of chromatic aberration

## > My Scripts
- Increased the default size limit of `adobeTemp()` from `15GB` -> `45GB`
- Added `SC03A & v` which makes all highlighted text lowercase
- Added `#c` to centre the active window on the main display
- Added `#f` to fullscreen the active window if it isn't already or release it from fullscreen if it is already
- `^AppsKey` now returns the original clipboard after completion

## > Resolve_Example.ahk
`Right Click to scrub timeline` >>
- Returned right click functionality when clicking on the scrubbing bar itself
- Right click scrubbing will now work regardless of the position of the scrub bar
- Right clicking will now function as expecting in tabs other than `Edit`

## > Other Changes
- Fixed `New Premiere.ahk` to work with `Premiere v22.3.1`
- Added `GoXLR` Backups
- Fixed overlap of two `F16` keys
- Updated comments to be more explanitory

`\Secondary Keyboard Files`
- Updated `mouse settings.png` as it was quite outdated
- Add keymap image to show the current way to adjust the backlight of my current secondary keyboard
- Added `Fkeys used.xlsx` to keep track of where fkeys beyond `F12` are being used
- Updated readne.md