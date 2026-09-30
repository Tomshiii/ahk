# <> Release 2.19.x - 

## Functions
- ✅ Fixed `rbuttonPrem().movePlayhead()` leaving mouse movement blocked if the user activates the function while dragging a panel

### 📝 `prem {`
- ✅ Fixed `dismissWarning()` potentially leaving inputs blocked
- ✅ Fixed `effectSlot()` potentially silently failing

### 📝 `PremiereRemote`
- 📋 `movePlayhead()`/`movePlayheadFrames()`/`moveClip()` no longer require parameter `subtract`