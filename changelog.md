# <> Release 2.19.x - 

## Functions

### 📝 `prem {`
- ✅ Fixed `dismissWarning()` potentially leaving inputs blocked
- ✅ Fixed `effectSlot()` potentially silently failing

### 📝 `rbuttonPrem {`
📍 `movePlayhead()`
- ✅ Fixed leaving mouse movement blocked if the user activates the function while dragging a panel
- ✅ Fixed `sendOnFailure` key not being sent if timeline values have not been set and no sequences are open

### 📝 `PremiereRemote`
- 📋 `movePlayhead()`/`movePlayheadFrames()`/`moveClip()` no longer require parameter `subtract`