# <> Release 2.10.x

## > Functions
- Fix `obj.imgSrch()` throwing if some object parameters were not set
- Fix `convert2()` throwing if explorer window is closed before function closes
- Fix `ae.timeline()` throwing if in the `Graph Editor`
- Add `obj.imgWait()`
- Moved function to retrieve `Premiere` `Timeline coordinates` => `prem.getTimeline()`
    - Fix function not using the correct coordinates and breaking unless the user's workspace was similar to my own
    - Coordinates now stored within `Prem {` class and can be shared
    - `right click premiere.ahk` & `prem.mousedrag()` now share those coordinates