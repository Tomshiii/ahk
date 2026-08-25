# <> Release 2.18.4.1 - Hotfix
Check out the [v2.18.4 changelog](<https://github.com/Tomshiii/ahk/releases/tag/v2.18.4>) for the recent big changes 

## Installation
- 📋 Installer will now attempt to reinstate the original `version`/`installDir`/`lib` files in the event of complete failure
    - Hopefully avoids situations where the installer fails part way through, then cannot be run again because `"This version is already installed"`

## Functions
- ✅ Fixed `ae.anchorToPosition()` not unblocking inputs
- ✅ Fixed `prem.layerSizeAdjust()` being unable to adjust a layer paritally off screen
- ✅ Fixed `cmd.result()` not working for some command types

## KSA
- ✏️ Added `premAddTracks`