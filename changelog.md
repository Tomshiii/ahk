# <> Release 2.14 - PremiereRemote, Premiere_UIA & Installation
This release brings about quite a few large and sweeping changes that expand on the functionality of the repo while also offering a few QOL improvements.

> [!Caution]
> Most of the changes in this update are breaking changes. It is recommended you do a clean installation of my repo if you intend on upgrading to this version.
***
## ‣ PremiereRemote
This release brings along support for [`PremiereRemote`](https://github.com/sebinside/PremiereRemote), a tool by [`sebinside`](https://github.com/sebinside) that allows the user to easily interact with [`Adobe Premiere's Extension mechanism`](https://github.com/Adobe-CEP).  
This tool offers multiple advantages for my repo, such as;  
- More directly telling Premiere to `save` resulting in less issues
- Directly change clip properties like `zoom`, `x/y`, `anchor point`, etc. Meaning less keystrokes needing to be sent
- Directly receive the current project path

> [!IMPORTANT]
> Use of `PremiereRemote` requires additional setup from the user so make sure you checkout the [wiki page](https://github.com/Tomshiii/ahk/wiki/PremiereRemote) to get started.

#### PremiereRemote related changes
- `winGet.ProjPath()` can now retrieve the project directory directly from Premiere without needing string manipulation
- `autosave.ahk` can now tell Premiere to save directly
- Added `openPremRemote.ahk` to quickly reopen the `PremiereRemote` extenstion within premiere.
    - **note: custom amount of "{Down}" will need to be set by the user*
- Added `openRemoteDir.ahk` to open the `A_AppData \Adobe\CEP\extensions\PremiereRemote\` directory
- Added `resetNPM.ahk` to rerun the `npm run build` command in the `A_AppData \Adobe\CEP\extensions\PremiereRemote\host\` directory
- Added `installPremRemote.ahk` that is optionally called during the new installation process.
    - **note: NodeJS must already be installed before this script will proceed.*

`Prem {`
- Added `__checkPremRemoteDir()` to check for the existence of the `PremiereRemote` extension
- Added `__checkPremRemoteFunc()` to check for the requested function to ensure it's callable
- Added `__remoteFunc()` to call functions for `PremiereRemote`
- Added `save()` to call the custom `saveProj` function and directly tell premiere to save instead of requiring keystrokes
- `zoom()` can now directly set the properties without needing to send keystrokes
- `Previews()` now attempts to use `save()` for a more reliable experience
***

## ‣ Premiere_UIA
This release brings exciting (but breaking) changes to `Premiere_UIA.ahk` and its use/functionality within the repo.
- `UIA` values are now stored in `..\Support Files\UIA\values.ini` instead of the class itself
    - Values are now stored in a `JSON` string instead of an ahk object
- Class must now be initialised before it can be used in another script
- `premUIA_Values {` can now automatically fill out UIA values by focusing each panel within `Premiere` and retrieving the UIA path
- `premUIA_Values(false).__setNewVal()` can be called to automatically generate new data for the currently set `Premiere` version
    - Class will automatically attempt to generate new data under certain circomstances
- `Set Prem_UIA values` can be selected from the `My Scripts.ahk` tray menu to automatically set new UIA values for the currently set `Premiere` version

> [!Tip]
> Checkout the updated [wiki](https://github.com/Tomshiii/ahk/wiki/UIA) page to learn more about these changes!
***

## ‣ Better Installation process of my repo
This release also offers a new and improved installation process which takes more of the work off the user to handle it systematically instead. The installation process should now be more akin to any other program you install on windows.

> [!Tip]
> Check the [Installation wiki page](https://github.com/Tomshiii/ahk/wiki/Installation) for more details.
***
# ‣ Further Changelog
## Functions
- Added `startup.adobeVerOverride()` which can optionally set the current `Premiere Pro`/`After Effects` version based off the user's current installed version instead of needing to manually be set.
    - **note: if the user wishes to use a beta version, the beta toggle must first be set and then the function must be rerun*
- Added `FileGetExtendedProp()` a function by `neogna2` to get extended properties of files/folders
- Fixed `switchTo.AE()` generating a shortcut using `UserSettings.prem_year` instead of `ae_year`
- Fixed `move.Window()` throwing in the event you try to minimize the active window the same moment it changes (and can no longer be found. eg opening a new browser tab)
- `cmd.result()` now accepts parameter `workingDir` to pass the working dir to `pipeCommand()` if parameter `hide` is set to `true`
- `prem.screenshot()` will now generate the dropdown list automatically using all filenames in `..\Streamdeck AHK\screenshots\`
    - **note: values will still need to be manually added to `WM {` however*

`settingsGUI()`
- Added option to enable/disable `startup.adobeVerOverride()`
- Added option to set `autosave.ahk` to always save or only save if the current program is the active window

## > Streamdeck AHK
- Fixed `reencode_prores_all.ahk` not doing anything
- `extractAll.ahk` now has protection against command growing too large

`2stereoTO1mono.ahk`
- Fixed script ignoring user input if a file already exists and the user chooses `Yes` in the dialogue box
- Now has protection against command growing too large

## > Other Changes
- Added [`WinEvent.ahk`](https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/WinEvent.ahk) by [Descolada](https://github.com/Descolada/)
    - `autodismiss error.ahk` now uses `WinEvent {`
- Added [SystemThemeAwareTooltip.ahk](https://github.com/nperovic/SystemThemeAwareToolTip) by [nperovic](https://github.com/nperovic)
    - `tool.cust()` now uses `SystemThemeAwareTooltip {` to set dark/lightmode tooltips as well as rounding them for win11
    - `Startup {` tooltips will now be coloured based off the system theme
- Now backing up `.prlabelpreset` file in `..\Backups\Adobe Backups\Premiere\Labels\`
- `checklist.ahk` now better handles my project folder paths
- `v24.3` of `Premiere` is now its own folder in `ImageSearch` as it contains UI changes

`adobeKSA.ahk`
- Fixed a bug that caused it to incorrectly set the default directory path for `After Effects`
- Patched a few instances of functions receiving blank variables - this is likely caused by a deeper issue and this bandaid solution has likely made things worse in the long run