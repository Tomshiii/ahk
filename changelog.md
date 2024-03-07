# <> Release 2.14 - PremiereRemote
> ### ⚠️ This branch will likely contain breaking changes for most of its development cycle. It is not recommended to use this branch ⚠️

***
## ‣ Premiere Remote
This release brings along support for [`PremiereRemote`](https://github.com/sebinside/PremiereRemote), a tool by [`sebinside`](https://github.com/sebinside) that allows the user to easily interact with [`Adobe Premiere's Extension mechanism`](https://github.com/Adobe-CEP).  
This tool offers multiple advantages for my repo, such as;  
- More directly telling Premiere to `save` resulting in less issues
- Directly change clip properties like `zoom`, `x/y`, `anchor point`, etc. Meaning less keystrokes needing to be sent
- Directly receive the current project path

It requires additional setup from the user so make sure you checkout the [wiki page](https://github.com/Tomshiii/ahk/wiki/PremiereRemote) to get started.

#### PremiereRemote related changes
- `winGet.ProjPath()` can now retrieve the project directory directly from Premiere without needing string manipulation
- `autosave.ahk` can now tell Premiere to save directly
- Added `openPremRemote.ahk` to quickly reopen the `PremiereRemote` extenstion within premiere.
    - **note: custom amount of "{Down}" will need to be set by the user*
- Added `openRemoteDir.ahk` to open the `A_AppData \Adobe\CEP\extensions\PremiereRemote\` directory
- Added `resetNPM.ahk` to rerun the `npm run build` command in the `A_AppData \Adobe\CEP\extensions\PremiereRemote\host\` directory
- Added `installPremRemote.ahk` that is potentially called during the new installation process.
    - **note: NodeJS must already be installed before this script will proceed.*

`Prem {`
- Added `__checkPremRemoteDir()` to check for the existence of the `PremiereRemote` extension
- Added `__checkPremRemoteFunc()` to check for the requested function to ensure it's callable
- Added `__remoteFunc()` to call functions for `PremiereRemote`
- Added `save()` to call the custom `saveProj` function and directly tell premiere to save instead of requiring keystrokes
- `zoom()` can now directly set the properties without needing to send keystrokes
- `Previews()` now attempts to use `save()` for a more reliable experience


## ‣ Better Installation process of my repo
This release also offers a new and improved installation process which takes more of the work off the user to handle it systematically instead. The installation process should now be more akin to any other program you install on windows.

Check the [Installation wiki page](https://github.com/Tomshiii/ahk/wiki/Installation) for more details.
***
## > Functions
- Fixed `switchTo.AE()` generating a shortcut using `UserSettings.prem_year` instead of `ae_year`
- `cmd.result()` now accepts parameter `workingDir` to pass the working dir to `pipeCommand()` if parameter `hide` is set to `true`

## > Other Changes
- Added [`WinEvent.ahk`](https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/WinEvent.ahk) by [Descolada](https://github.com/Descolada/)
    - `autodismiss error.ahk` now uses `WinEvent {`
- Now backing up `.prlabelpreset` file in `..\Backups\Adobe Backups\Premiere\Labels\`
- `checklist.ahk` now better handles my project folder paths
- `v24.3` of `Premiere` is now its own folder in `ImageSearch` as it contains UI changes

`adobeKSA.ahk`
- Fixed a bug that caused it to incorrectly set the default directory path for `After Effects`
- Patched a few instances of functions receiving blank variables - this is likely caused by a deeper issue and this bandaid solution has likely made things worse in the long run