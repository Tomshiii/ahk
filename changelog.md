# <> Release 2.14.x - Premiere Pro Spectrum UI Support
This release brings support for the new Premiere Pro UI currently being tested in the beta channels. As it is currently in beta, things may continue to change in the future as they lead up to its release in a few months.

> [!Important]
> It should be noted that in the current beta versions of Premiere Pro, adobe has removed the Title from the `"delete existing keyframes"` window. This change completely breaks `autodismiss error.ahk` and unless adobe reverts this change, this script will no longer be able to function.

## Functions

`rbuttonPrem {`
- Now requires an additional parameter `version` to tell the function which version of `Premiere` is set within `settingsGUI()`
- Now supports both the current UI colours and the new `Spectrum` UI found in current beta builds
- The `sleep` in the main `while` loop has been doubled to give premiere time to catch up from the sea of inputs its receiving. The extra delay isn't visually percievable

`prem {`
- `prem.selectionTool()` & `prem.screenshot()` now properly block user inputs when they're supposed to
- Now stores `UserSettings.premVer` so that `rbuttonPrem().movePlayhead()` can more easily use it as a parameter
- Removed `audioDrag()`

## Other Changes
- Removed a lot of old `Premiere` `ImageSearch` files that are no longer used in any functions
- `swap solo.ahk` will now properly retrieve the coordinates of the timeline if the `Main Script` doesn't have them yet