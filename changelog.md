# <> Release 2.18.x - 

## Functions
- ✏️ Added `Base64Encode()`

### 📝 `prem {`
- ✏️ Added `effectSlot()`
- 📋 `toggleEnabled()` now accepts `"settings"` in parameter `ignore`

## Other Changes
- ✅ Fixed <kbd>MButton</kbd> getting disabled in some instances due to a settings mismatch with `Thio's MButton Script`
- ✏️ Added setting `toggleEnabled_ignore`
- ✏️ Added initial support for the `UXP` version of `PremiereRemote`
    - All possible functions have been ported<sup>[[list]](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=202913119>)
> [!Warning]
> Full `CEP` feature parity has not yet been achieved in `UXP` and as such, some functions are currently unable to be ported. You can see which functions lack api support here [here](<https://github.com/users/Tomshiii/projects/1?pane=issue&itemId=202913119>)
- 📋 `openPremRemote` now uses `MenuSelect` instead of sending keystrokes