# <> Release 2.14.5 - Initial Adobe Spectrum UI Support
This release brings initial support for the new Premiere Pro & After Effects `Spectrum UI` currently being tested in the beta channels. Be aware that, as it is currently in beta, things may continue to change in the future as they lead up to its release in a few months. As such my scripts may lag behind in support as a result.  
It should also be noted that while the current UI overhaul is in the `v24.5` betas, there is no guarantee that will be the version it launches in (colour label changes were initially in the premiere `v24.3` beta but pushed to `v24.4` for example), because of this, the user should be aware that the `ImageSearch` folders in `..\Support Files\ImageSearch\Premiere` may not be completely accurate after release and adobe may change things.

> [!Important]
> It should be noted that in the current beta versions of Premiere Pro, adobe has removed the WinTitle from the `"delete existing keyframes"` window. This change completely breaks `autodismiss error.ahk` and unless adobe reverts this change, this script will no longer be able to function.

## Functions
- Fixed `prem.preset()` potentially throwing if it cannot determine the position of the caret
- Removed `ae.valuehold()` & `ae.preset()`

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
- Removed a lot of old `Premiere` & `After Effects` `ImageSearch` files that are no longer used in any functions
- `swap solo.ahk` will now properly retrieve the coordinates of the timeline if the `Main Script` doesn't have them yet