# <> Release 2.16.x - 

## Functions
- ✅ Fixed `slack.button()` throwing in certain circumstances

### 📝 `prem {`
- ✅ Fixed `anchorToPosition()` not working correctly in versions `25.4` and greater
- ✅ Fixed `dismissWarning()` firing on seemingly non existent windows
- 📋 `layerSizeAdjust()` now accepts parameter `middle` to determine if you wish to adjust the middle divider instead of the track height
- 📋 `__setCurrSeq()` should no longer flood the line execution
- 📋 `gain()` will now highlight the text input field in the event the gain window is already open, but a text field is not selected

### 📝 `explorer {`
- ✏️ Added class `explorer {`
- ✏️ Added `cancelSearch()`
- 📋 Moved `switchTo.explorerHighlightFile()` => `highlightFile()`
- 📋 Moved `nItemsInDir()`
- 📋 Moved `selectFileInOpenWindow()`
- 📋 Moved `winget.getActiveExplorerTab()` => `getTab()`
- 📋 Moved `winget.ExplorerPath()` => `getPath()`