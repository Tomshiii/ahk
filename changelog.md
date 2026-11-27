# <> Release 2.21.x - 

## Functions
- ✅ Fixed `determineAdobeVer()` sometimes failing to return proper values for `Photoshop`
- ✅ Fixed `getLocalVer()` using incorrect logic to set a variable
- ✅ Fixed `rbuttonPrem().movePlayhead()` checking `timelineColArr` indexes that don't exist

### 📝 `prem {`
- ✏️ Added `isOperating()`
- ✅ Fixed `__setEffContScrollbar()` causing functions to throw if no vertical scroll bar was present
- ✅ Fixed `isClipUnderCursor()` checking `timelineColArr` indexes that don't exist
- 📋 `getTimeline()` now accepts param `override` to update `Core Functionality.ahk` values
    - `__setRemoteIcon()`/`startup().trayMen()` will now update timeline values if the `UIA`/`Reload UIA` buttons are clicked

### 📝 `PremiereRemote`
- ✏️ Added `custom/filterSelectionByDisabled()`

### 📝 `slack {`
- ✏️ Added `exitThread()`
- ✅ Fixed `button()` sometimes doing nothing on first use
- ✅ Fixed inputs getting stuck blocked if slack is closed then reopened

## Other Changes
- ❌ Removed `My Scripts.ahk`/`QMK.ahk`/`Resolve_Example.ahk`, all hotkey assignments, and moved them into a [separate repo](<https://github.com/Tomshiii/tomshi-hotkeys>)