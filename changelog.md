# <> Release 2.14.x - 
- Fixed `startup.adobeVerOverride()` failing to determine beta exe paths correctly & causing a boot loop

## Functions
- `getLocalVer()` now accepts parameter `returnObj` to determine whether just to return the version number of a script as a string, or whether to return an object containing both the version number & the entire contents of the passed script
    - `startup.libUpdateCheck()` now uses this function instead of repeating code
        - Fixes `startup.libUpdateCheck()` sometimes incorrectly determining version numbers
- `startup.libUpdateCheck()` now uses `Notify {` in a few cases

`settingsGUI()`
- Fixed the bottom checkboxes getting cut off
- Fixed function throwing if the user attempts to open the `Photoshop` dropdown menu