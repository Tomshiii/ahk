# <> Release 2.19.x - 

## Functions
- ✏️ Added `statusIcon {`
- ✅ Fixed `settings.ini` values getting reset if a key is added
- 📋 Increased default `adobe_GB` value from `45` => `100`

### 📝 `prem {`
- ✅ Fixed `dismissWarning()` potentially leaving inputs blocked
- ✅ Fixed `effectSlot()` potentially silently failing
- ✅ Fixed `__checkPremRemoteFunc(, "uxp")` not doing the `isInstalled` checks
- ✅ Fixed class not actually polling the `uxp` socket
- 📋 `PremiereRemote` functions are now checked using `PremiereRemote`'s internal registry instead of string manipulation
- 📋 Slight optimisations to `toggleLayerButtons()`

### 📝 `rbuttonPrem {`
📍 `movePlayhead()`
- ✅ Fixed function leaving mouse movement blocked if the user activates the function while dragging a panel
- ✅ Fixed `sendOnFailure` key not being sent if timeline values have not been set and no sequences are open

### 📝 `PremiereRemote`

📍 `UXP`
- ✅ Fixed `saveEffectSlotJSON()`/`applyEffectSlotJSON()`
- ✅ Fixed `matchSelectedClipsToLowestTrack()` throwing in some scenarios
- 📋 Adjust multiple functions to retrieve information concurrently
- 📋 Moved alot of functions into their own files to organise them a bit better
    - `replacePremRemote.ahk` will now work correctly for any `.ts` files stored in folders
- 📋 `getPlayheadPosTimecode()` will now use internal function `timeToTimecode()` in `v27.0+`

📍 `Both`
- ✏️ Added `getRegistryJSON()`
- 📋 `movePlayhead()`/`movePlayheadFrames()`/`moveClip()` no longer require parameter `subtract`

### 📝 `AERemote`
- ✏️ Added `getRegistryJSON()`

## Other Changes

🔗 `determineUIA.ahk`
- ✅ Fixed function failing to properly close during `reloadAll.ahk`
- 📋 Will now show a status icon for the connection status of the `cep` & `uxp` sockets/panels
    - Can be disabled in `settingsGUI()`  
    <img width="222" height="74" alt="cep_uxp_status" src="https://github.com/user-attachments/assets/0713ea6f-e8b7-4aa4-a54d-f8a03710e2a1" />