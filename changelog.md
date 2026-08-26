# <> Release 2.18.x - 

## Functions
- ✅ Fixed `premUIA_Values.__activeElementPath()` throwing in certain circumstances causing `determineUIA.ahk` to crash
- 📋 `prem/ae.anchorToPosition()` now attempts to use the api to adjust the values before falling back to clipboard manipulation

## PremiereRemote
- ✏️ Added `syncTransformAnchorToPosition()`

## AERemote
- ✅ Fixed extension failing to appear (mb I forgot to edit some files)
    - If already installed, will need to be reinstalled
- ✏️ Added ports of `applyEffectOnAllSelectedClips()`, `listEffectsOnSelectedClip()`, `syncTransformAnchorToPosition()`, `isSelected()`, `isSelectedMultiple()`