# <> Release 2.14.6 - Hotfix
- Fix a bug in `startup.adobeVerOverride()` that caused any subsequent startup scripts to no longer run
    - As a result this release also includes a bunch of third party lib updates

## Functions
- Removed `prem.wordBackspace()`
- Added `prem.swapChannels()` by taking code from `swapChannels.ahk`

## Other Changes
- Added `Notify.ahk` by `XMCQCX`
    - `autosave.ahk`, `premUIA_Values().__setNewVal()` & `prem.getTimeline()` now use `notify {` instead of `tool.Cust()` for a cleaner user experience
    - `startup.libUpdateCheck()` currently checks against a fork I created but will be adjusted back to the main branch once it supports center aligning text