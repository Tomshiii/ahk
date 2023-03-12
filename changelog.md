# <> Release 2.10.x

## > Functions
- Fix `obj.imgSrch()` throwing if some object parameters were not set
- Fix `convert2()` throwing if explorer window is closed before function finalises
- Fix `ae.timeline()` throwing if in the `Graph Editor`
- Add `obj.imgWait()`
- Add `move.Adjust()`
- Add `change_msgButton()`
- `ytDownload()` can now download twitch clips
- Moved function to retrieve `Premiere` `Timeline coordinates` => `prem.getTimeline()`
    - Fix function not using the correct coordinates and breaking unless the user's workspace was similar to my own
    - Coordinates now stored within `Prem {` class and can be shared between functions
    	- `right click premiere.ahk` & `prem.mousedrag()` now share those coordinates
- `Discord {` functions will now alert the user if the logo has changed and may require new screenshots

## > Other Changes
- Add `mov2mp4.ahk`