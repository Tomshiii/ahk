# <> Release 2.19.x - 

## Functions
- ✏️ Added `statusIcon {`, `cursor {`
- ✏️ Added `obj.isEqual()`
- ✅ Fixed `settings.ini` values getting reset if a key is added
- ✅ Fixed `adobeXML {` flooding the logs with empty values when a hotkey isn't found
- 📋 Increased default `adobe_GB` value from `45` => `100`
- 📋 Moved `XorY()`, `clipMouse()`, and `setMouseClip()` from `move {` => `cursor {`

### 📝 `prem {`
- ✅ Fixed `dismissWarning()` potentially leaving inputs blocked
- ✅ Fixed `effectSlot()` potentially silently failing
- ✅ Fixed `__checkPremRemoteFunc(, "uxp")` not doing the `isInstalled` checks
- ✅ Fixed class not actually polling the `uxp` socket
- ✅ Fixed `uxp` panel being marked as open even when it wasn't
- 📋 `PremiereRemote` functions are now checked using `PremiereRemote`'s internal registry instead of string manipulation
- 📋 Slight optimisations to `toggleLayerButtons()`
- 📋 `swapPreviousSequence()` now requires the `UXP` `PremiereRemote` extension
    - All swapping/sequence storing logic is now held within the plugin's memory using [`Sequence Events`](<https://developer.adobe.com/premiere-pro/uxp/ppro-reference/constants/#sequenceevent>)

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
- 📋 `UIA` tree can now be regenerated from any script by calling `premUIA_Values.forceReset()`
- 📋 Will now show a status icon for the connection status of the `cep` & `uxp` sockets/panels & the current `UIA` tree
    - Can be disabled in `settingsGUI()`  
    <img width="219" height="67" alt="statusIcons" src="https://github.com/user-attachments/assets/88771f4a-ef08-4ca1-b4e5-63080158570e" />