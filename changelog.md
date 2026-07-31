# <> Release 2.18.x - 

## Functions
- ✅ Fixed `ytdlp.download()` failing to add `cookies` to some commands

### 📝 `prem {`
- ✅ Fixed `__determineTheme()` using an incorrect `__remoteFunc()` parameter
- ✅ Fixed `gain()` failing when multiple clips are selected
- 📋 `renderProjectSelection()` will now import the file into the same bin as the sequence being rendered

📍 `__remoteUXP()`
- 📋 Will now alert the user if a parameter is required to be a `boolean` and they have passed `0`/`1` instead of `false`/`true`
- 📋 Will now return boolean `true`/`false` instead of a string for parity with `__remoteFunc()`

## PremiereRemote
- ✏️ Added `isSelectedMultiple()` 

📍 `applyEffectOnAllSelectedClips()`
- ❗ Parameter name changed from `effect` to `effectName` for parity
- ✅ Fixed effects like `Geometry2` from erroring out

## Other Changes

🔗 `mult-dl.ahk`
###### *(v1.3.6 -> v1.3.8.1)*
- 📋 Now requires (and prompts the user to update to) the nightly builds of `yt-dlp` to ensure quicker patches
- 📋 Now tracks a users `use cookies` preference
- 📋 `Part` now bakes `--sleep` into the command to appease the youtube gods