# <> Release 2.12.x - 
- It is now possible to mark versions of `After Effects` & `Premiere Pro` as `Beta` within `settingsGUI()` to bring compatibility to the beta versions of both programs.
- Removed use of `_DLFile.ahk` to allow `startup.updateChecker()` & `startup.updateAHK()` to function correctly

## > Functions
- Fixed `fastWheel.ahk` throwing if it cannot determine the active window
- Fixed `prem.preset("loremipsum")` throwing
- `settingsGUI()` will now produce a TrayTip when closed to visually show that changes are being saved
- `tool.wait()` will no longer infinitly wait for the `Startup {` tooltips
- `obj.MousePos()` no longer attempts to retrieve the `Control` under the cursor. Doing so was causing the script to throw if the cursor was hoving an element of Windows that does not contain a control. (ie. the taskbar/start menu)
- `cmd.Run()` now accepts new parameter `keepWindow` to determine whether the `cmd` window will close once completed. Defaults to `false`
- `yt-dlp {` now supports tiktok links
- `discord.button("DiscReply.png")` automatically disabling the `@` ping can now be enabled/disabled within `settingsGUI()`

`Move {`
- Added `winCenterWide()` to center windows fullscreen on the users main monitor. Mainly useful for ultrawide monitors
- `winCenter()` now accepts parameter `adjustHeight` to increase the height of a centred window

## > autosave.ahk
- Attempted to fix `autosave.ahk` infrequently throwing
- Fix `__fallback()` attempting to call non existent variable `this.__checkPlayback` instead of the function `this.__checkPlayback()`
- Manually saving within `Premiere` or `After Effects` will now reset `autosave` timer. (adjustable within `settingsGUI()`)

## > Other Changes
- Added `;SubUnderHotkey;`
- Added `generateAdobeSym.ahk`
- `;numpadytHotkey;` will no longer block inputs in `YouTube Studio`
- If `After Effects` **isn't** open, `sendToAE.ahk` will now ask the user if they wanted to open an existing AE project or create a new one.