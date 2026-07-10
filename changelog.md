# <> Release 2.18.1 - Rudimentary UXP 'Support'

> [!Warning]
> I am aware of an issue that may cause some (seemingly unrelated) scripts to throw if `Premiere` or `After Effects` is not installed. This was originally designed to be intentional behaviour to stop the user from attempting to use functions for a program they didn't even have installed.  
> The implementation of this feature was short sighted however and may cause a script to throw simply because somewhere in the chain `prem {` or `ae {` is imported for one reason other another.  
> Although this release does not contain a fix for this issue, it is my intention to address this in the future. <sup>[[1]](<https://github.com/users/Tomshiii/projects/1/views/1?pane=issue&itemId=209528690>)</sup>

## Functions
- ✏️ Added `Base64Encode()`
- ✅ Fixed `premUIA_Values.setObjs()` failing to build the UIA tree if there are any floating panels

### 📝 `prem {`
- ✅ Fixed `renderAndReplace()` halting after setting the preset even if it was successful
- ✏️ Added `effectSlot()`
- 📋 `toggleEnabled()` now accepts `"settings"` in parameter `ignore`

### 📝 `startup {`

📍 `adobeVerOverride()`
- ✅ Fixed failing to update versions properly
- ✅ Fixed function not properly updating `UserSettings`


## Other Changes
- ✅ Fixed <kbd>MButton</kbd> getting disabled in some instances due to a settings mismatch with `Thio's MButton Script`
- ✅ Fixed `generateAdobeShortcut.ahk` throwing when passed an object instead of a `ComObject`
- ✏️ Added setting `toggleEnabled ignore`

### 📝 `PremiereRemote`
- ✅ Fixed (hopefully) `applyEffectOnAllSelectedClips()` sometimes silently failing to add an effect
- ✏️ Added initial support for the `UXP` version of `PremiereRemote`
    - All possible functions have been ported<sup>[[list]](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=202913119>)
    - The installation of the `UXP` version of `PremiereRemote` is not currently supported (or recommended) as it is still actively being developed. Additionally, adobe hasn't really made the switch yet themselves.  
    As such; the support in this repo is **strictly for testing purposes**
> [!Warning]
> Full `CEP` feature parity has not yet been achieved in `UXP`, and as such, some functions are currently unable to be ported. You can see which functions lack api support here [here](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=202913119>).  
> Additionally, these `UXP` variations have not been thoroughly tested beyond an initial debug pass. Use at your own risk but feel free to report any issues.
- 📋 `openPremRemote` now uses `MenuSelect` instead of sending keystrokes