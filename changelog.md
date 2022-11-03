# <> Release 2.6.x - 
`class ptf {` (point to file)
- Replace `ImageSearch` `global variables` path variables
- Add as many directory locations as possible as class variables
- Add as many file directory locations as a map `files`

## > My Scripts
`#c::`
- Will now ensure the `monitor` object is actually set before continuing to stop errors
- Fixed bug where if the window was overlapping multiple monitors, it would error and fail to center the window

## > Functions
- Fixed `activeScripts()` being unable to relaunched if closed with `x` windows button

## > Other Changes
- Removed a lot of lingering `location` variables from `Streamdeck AHK` scripts

`checklist.ahk`
- Changed `msgboxName()` to `change_msgButton()` to stop incorrect autocomplete in VSCode