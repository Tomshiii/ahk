# <> Release 2.14.x - 

## Functions
- Added a button/Menu option to `settingsGUI()` that links to a wiki page explaining what all the settings do

`premUIA_Values {`
- `__setNewVal()`
    - Will now block inputs while it is interacting with Premiere so the user cannot interrupt it
    - Will now ensure playback has halted before continuing as UIA can become incredibly unresponsive during playback