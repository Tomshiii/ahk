# <> Release 2.18.0 - Premiere 26.2+ Support
# 🔸UIA
This release brings support for `Premiere 26.2+`.  
This required a rather extensive rewrite to all `UIA` related code and as such removes compatibility with Premiere versions prior to `26.2`.  

> [!Important]
> You may notice that gathering UIA information is no longer *(practically)* instant; this was in large part the reason this release required my UIA related code to be rewritten from the ground up.  
> As it can take upwards of 5-10s to generate, the UIA tree is now generated once and is then shared amongst all scripts as they require it.  

<img width="527" height="212" alt="Adobe_Premiere_Pro_X5naawl7SI_2" src="https://github.com/user-attachments/assets/ee8b9ec6-b9dd-4583-870f-9a19c47c15f6" />

# 🔸Patches
Following some groundwork laid in previous releases, versions beyond Release 2.18.0 will now be able to be installed as a `patch` instead of **requiring** the user to completely reinstall the repo.  
In the future this will hopefully allow me to release critical fixes a little quicker instead of somewhat incentivising myself to wait for a larger update.

# 🔸PremiereRemote & nodeJS
- [`PremiereRemote`](<https://github.com/sebinside/PremiereRemote>) is now **required**. And will be installed during installation of my repo.
    - As a result, `nodejs` will be bundled alongside my repo and installed for the user if not available prior.

> [!Warning]
> It should be noted the installation process for `PremiereRemote` requires a registry edit. If the user would like to know details about why this adjustment is required, they can read the installation requirements for PremiereRemote<sup>[[1]](<https://github.com/sebinside/PremiereRemote/tree/main#installation>)</sup>.  
> If the user would like to see the exact change the installation process is making, they can check the installation script.<sup>[[2]](<https://github.com/Tomshiii/ahk/blob/77f79732ce12e6cb6e714b576ec72eff70ba8ba1/Support%20Files/Release%20Assets/Install%20Packages/installPremRemote.ahk#L36>)</sup>
***

## Functions
- ✅ Fixed `settingsGUI()` not generating the proper `Premiere` shortcut when the `beta` checkbox is deselected
- ✅ Fixed `CLSID_Objs.Clone()` only being a shallow clone
- ✏️ Added `checkINI()`, `determineAdobeVer()`
- 📋 `WM.Send_WM_COPYDATA()` now accepts param `doTooltips`
- ❌ Removed `hotkeysGUI()`


### 📝 `prem {`
- ❗ Support for `v26.2+`
    - ❗ Removed support for versions below `v26.2`
- ❗ Will now check for `Node.js` & `PremiereRemote` at runtime
- ✅ Fixed `isEditTabActive()` throwing in some circumstances
- ✏️ Added `setRnderRplcPreset()`, `setRnderRplcPath()`, `renderAndReplace()`, `goToLastProjPanelItem()`, `setBlendMode()`
- 📋 UIA values will now be reset on Premiere close
- 📋 Changed `prem.selectionTool()` => `prem.selectTool()`
    - Can now set any tool set within `Premiere_UIA.ahk`

### 📝 `startup {`
- ✅ Fixed an issue with `updateCheckGUI.ahk` using outdated `WebView2` code and subsequently throwing
- ❌ Removed `generate()`, `firstCheck()`, `todoGUI()`

📍 `updateChecker()`
- ✅ Fixed function throwing if the user attempted to download an update from the GUI
- 📋 Will now download and install patches for future versions

### 📝 `Settings {`
- ✏️ Added `Set_UIA_on_reload`
- ❌ Removed `Always_Check_UIA`, `Set_UIA_Limit_Daily`, `MainScriptName`
- ✅ Fixed not formatting `beta`/`alpha`/`pre` versions correctly
- 📋 Will now check the user's `.ini` file against a fresh template during the `Core Functionality.ahk` initialisation flow
    - 📋 `Core Functionality.ahk` will now ensure stale values are removed
- 📋 Changed values will now instantly write new value to `ini` file instead of relying on object cleanup.
    - Should address issues with settings changes not sticking during reloads

### 📝 `notifyExt {`
- ❗Added class `notifyExt {`
- ✏️Added `destroyDupes()`, `checkMultiple()`, `deleteIfExist()`

📍 `notifyIfNotExist()`
- 📋 Renamed `notifyIfNotExist()` => `showIfNotExist()`
- 📋 Moved function into `notifyExt {` class
- 📋 Will now send its request to be handled by `Core Functionality.ahk`
    - ✅ Fixes `Notify` windows called during `HotkeylessAHK` functions causing the script to hang if they are still active once the function has finished executing

### 📝 `KSA {`
- ❗ `KSA` values are now shared using `Core Functionality.ahk`
- ❗ `Premiere`, `After Effects` & `Photoshop` hotkeys are now automatically generated using the user's current keyboard shortcuts

### 📝 `WinGet {`

📍 `PremName()`
- ✅ Fixed function failing to determine `beta` titles correctly
- ✅ Fixed function sometimes thinking `Premiere` isn't open

## Other Changes
- ❌ Removed `..\Support Files\Streamdeck Files`, `..\Streamdeck AHK\run & activate\`, `Streamdeck_opt.ahk`, `enable unsigned extensions.ahk`, `render and replace.ahk`, `partDL.ahk`, `adobeKSA.ahk`
- ✅ Fixed numerous issues affecting installation
- ✅ Fixed `Multi-Instance Close.ahk`, `adobe fullscreen check.ahk` & `gameCheck.ahk` stalling `reloadAll.ahk`/`closeAll.ahk`
- 📋 `autosave.ahk` will now only check if the user is idle while attempting to save `Premiere` if it is the active window