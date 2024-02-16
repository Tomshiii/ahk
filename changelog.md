# <> Release 2.13.x - 

## > Functions

`settingsGUI()`
- Fixed `Adobe` settings generating incorrect values
- `Adobe` settings will now only present the user with versions of `Premiere` & `After Effects` that they have installed. `Photoshop` will show any versions they have installed +- 1 as their numbering system is a bit weird and I have no intention of keeping a catelogue of what version relates to which year

## > Other Changes
- Fixed `generateAdobeSym.ahk` silently failing if build command got too long
- Added `selectFollowPlayhead.ahk`