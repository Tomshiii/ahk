# <> Release 2.18.x - 

## Functions
- ✏️ Added `Base64Encode()`
- ✅ Fixed `startup.adobeVerOverride()` failing to update versions properly
- ✅ Fixed `premUIA_Values.setObjs()` failing to build the UIA tree if there are any floating panels

### 📝 `prem {`
- ✏️ Added `effectSlot()`
- 📋 `toggleEnabled()` now accepts `"settings"` in parameter `ignore`

## Other Changes
- ✅ Fixed <kbd>MButton</kbd> getting disabled in some instances due to a settings mismatch with `Thio's MButton Script`
- ✅ Fixed `generateAdobeShortcut.ahk` throwing when passed an object instead of a `ComObject`
- ✏️ Added setting `toggleEnabled_ignore`
- ✏️ Added initial support for the `UXP` version of `PremiereRemote`
    - All possible functions have been ported<sup>[[list]](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=202913119>)
> [!Warning]
> Full `CEP` feature parity has not yet been achieved in `UXP` and as such, some functions are currently unable to be ported. You can see which functions lack api support here [here](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=202913119>).  
> Additionally, these `UXP` variations have not been thoroughly tested beyond an initial debug pass. Use at your own risk but feel free to report any issues.
- 📋 `openPremRemote` now uses `MenuSelect` instead of sending keystrokes