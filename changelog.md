# <> Release 2.14.5 - Initial Premiere Pro Spectrum UI Support
This release brings initial support for the new Premiere Pro UI currently being tested in the beta channels. Be aware that, as it is currently in beta, things may continue to change in the future as they lead up to its release in a few months and as such my scripts may lag behind in support as a result.

> [!Important]
> It should be noted that in the current beta versions of Premiere Pro, adobe has removed the WinTitle from the `"delete existing keyframes"` window. This change completely breaks `autodismiss error.ahk` and unless adobe reverts this change, this script will no longer be able to function.

## Functions

`rbuttonPrem {`
- Now supports both the current UI colours and the new `Spectrum` UI found in current beta builds
    - Timeline colour values have been taken out of this class and placed in their own class `timelineColours {` to tidy things up and add easier support for multiple UI versions
- `movePlayhead()` now requires an additional parameter `version` to tell the function which version of `Premiere` is set within `settingsGUI()`
    - Now also takes additional parameter `theme` to use a different theme than the default `darkest`. However, doing so will require the user to add additional colour values to `timelineColours {` for their desired theme as I only maintain `darkest`. Feel free to pull request other themes back to the repo!
- The `sleep` in the main `while` loop of `movePlayhead()` has been doubled to give premiere time to catch up from the sea of inputs it's receiving. The extra delay isn't visually percievable

`prem {`
- `prem.selectionTool()` & `prem.screenshot()` now properly block user inputs when they're supposed to
- Now stores `UserSettings.premVer` as `currentSetVer` so that `rbuttonPrem().movePlayhead()` can more easily use it as a parameter
- Removed `audioDrag()`

## Other Changes
- Removed a lot of old `Premiere` `ImageSearch` files that are no longer used in any functions
- `swap solo.ahk` will now properly retrieve the coordinates of the timeline if the `Main Script` doesn't have them yet