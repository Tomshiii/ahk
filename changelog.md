# <> Release 2.18.5 - KSA Changes

## KSA
- ❗ All `KSA` variables are now prefixed by their respective program, ie; `KSA.prem.timelineWindow`/`KSA.ae.previousKeyframe`/etc
    - This will now require the `override.json` file to be structured similarly. Checkout the updated wiki<sup>[[1]](<https://github.com/Tomshiii/ahk/wiki/Keyboard-Shortcut-Adjustments>)</sup> for more information on the updated formatting.
- ✅ Fixed unhelpful errors when a keyboard shortcut isn't set

## Functions
- ✅ Fixed `premUIA_Values.__activeElementPath()` throwing in certain circumstances causing `determineUIA.ahk` to crash
- 📋 Shared `CLSID_Objs` objects should now be less likely to get stuck in a locked state

### 📝 `prem {`
- 📋 `anchorToPosition()` now attempts to use the api to adjust the values before falling back to clipboard manipulation
- 📋 `save()` will now abort early if a `Save Project` window already exists

### 📝 `ae {`
- ❌ Removed `scaleAndPos()`, `motionBlur()`
- ✏️ Added `isToolSelected()`, `isClipSelected()`
- 📋 Port `prem.save()` to `ae.save()`
- 📋 `anchorToPosition()` now attempts to use the api to adjust the values before falling back to clipboard manipulation

## PremiereRemote
- ✏️ Added `anchorToPosition()`

## AERemote
- ✏️ Added ports of `applyEffectOnAllSelectedClips()`, `listEffectsOnSelectedClip()`, `anchorToPosition()`, `isSelected()`, `isSelectedMultiple()`

## Other Changes
- ❌ Removed AE `advancedX.png`, `blurX.png`, `mode.png`, `toggle.png`, `text.png`, `shutterangle.png`
- ❌ Removed `adjustment layer.ahk`, `obs_screenshot.ahk`, `start main stream.ahk`, `close stream.ahk`, `disable obs preview.ahk`, `enable obs preview.ahk`, `focusChat.ahk`, `open mii wii program.ahk`, `quick sound settings.ahk`, `powerpoints.ahk`, `start botshi stream.ahk`

🔗 `mult-dl.ahk`
###### *(v1.3.11 -> v1.3.13)*
- 📋 `Multi` list will now be cleared once downloading has completed
- 📋 `Multi` will now accept a `,` delimited list of url's to add