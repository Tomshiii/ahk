# <> Release 2.18.0 - Premiere 26.2+ Support
## > `UIA`
This release brings support for `Premiere 26.2+`. This required a rather extensive rewrite to all `UIA` related code and as such removes compatibility with Premiere versions prior to `26.2`.  

> [!Important]
> You may notice that gathering UIA information is no longer *(practically)* instant; this was in large part the reason this release required my UIA related code to be rewritten from the ground up. As it can take upwards of 5-10s to generate, the UIA tree is now generated once and is then shared amongst all scripts as they require it.  

<img width="527" height="212" alt="Adobe_Premiere_Pro_X5naawl7SI_2" src="https://github.com/user-attachments/assets/ee8b9ec6-b9dd-4583-870f-9a19c47c15f6" />

## > `PremiereRemote`
- [`PremiereRemote`](<https://github.com/sebinside/PremiereRemote>) is now **required**. And will be installed during installation of my repo.
    - As a result, `nodejs` will be bundled alongside my repo and installed for the user if not available prior.

> [!Warning]
> It should be noted the installation process for `PremiereRemote` requires a registry edit. If the user would like to know details about why this adjustment is required, they can read the installation requirements for PremiereRemote<sup>[[1]](<https://github.com/sebinside/PremiereRemote/tree/main#installation>)</sup>.  
> If the user would like to see the exact change the installation process is making, they can check the installation script.<sup>[[2]](<https://github.com/Tomshiii/ahk/blob/77f79732ce12e6cb6e714b576ec72eff70ba8ba1/Support%20Files/Release%20Assets/Install%20Packages/installPremRemote.ahk#L36>)</sup>
***

## Functions
- ✅ Fixed `settingsGUI()` not generating the proper `Premiere` shortcut when the `beta` checkbox is deselected
- ✏️ Added `checkINI()`, `determineAdobeVer()`

### 📝 `WinGet {`

📍 `PremName()`
- ✅ Fixed function failing to determine `beta` titles correctly
- ✅ Fixed function sometimes thinking `Premiere` isn't open

### 📝 `prem {`
- ❗ Support for `v26.2`
- 📋 UIA values will now be reset on Premiere close
- 📋 Changed `prem.selectionTool()` => `prem.selectTool()`
    - Can now set any tool set within `Premiere_UIA.ahk`
- ✅ Fixed `isEditTabActive()` throwing in some circumstances

### 📝 `startup {`
- ✅ Fixed an issue with `updateCheckGUI.ahk` using outdated `WebView2` code and subsequently throwing
- ✅ Fixed `updateChecker()` throwing if the user attempted to download an update from the GUI

### 📝 `Settings {`
- ✏️ Added `Set_UIA_on_load`
- ❌ Removed `Always_Check_UIA`, `Set_UIA_Limit_Daily`, `MainScriptName`
- 📋 Will now check the user's `.ini` file against a fresh template during the `Core Functionality.ahk` initialisation flow

### 📝 `notifyExt {`
- ❗Added class `notifyExt {`
- ✏️Added `destroyDupes()`, `checkMultiple()`, `deleteIfExist()`

📍 `notifyIfNotExist()`
- 📋 Renamed `notifyIfNotExist()` => `showIfNotExist()`
- 📋 Moved function into `notifyExt {` class
- 📋 Will now send its request to be handled by `Core Functionality.ahk`
    - ✅ Fixes `Notify` windows called during `HotkeylessAHK` functions causing the script to hang if they are still active once the function has finished executing

### 📝 `KSA {`
- 📋 Moved the active `Keyboard Shortcuts.ini` file to `A_MyDocuments\tomshi\Keyboard Shortcuts.ini`
    - Moved the template file from `..\Support Files\KSA` => `A_AppData\tomshi\lib\KSA`
    - Will check the user's current ini file against the template
- 📋 `KSA` values are now shared using `Core Functionality.ahk`

## Other Changes
- ❌ Removed `..\Support Files\Streamdeck Files`, `..\Streamdeck AHK\run & activate\`, `Streamdeck_opt.ahk`, `..\Streamdeck AHK/PremiereRemote/enable unsigned extensions.ahk`
- ✅ Fixed `Multi-Instance Close.ahk` stalling `reloadAll.ahk`