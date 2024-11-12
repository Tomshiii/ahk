# <> Release 2.15 - 
> [!Important]
> If the user has previously used `PremiereRemote` with my scripts this version will require them to copy all relevent files in `..\Backups\Adobe Backups\Premiere\PremiereRemote\` and replace the corresponding files in `A_AppData "\Adobe\CEP\extensions\PremiereRemote\` or alternatively run `...\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk`.

> [!Caution]
> If the user uses `UIA` with `Premiere` functions, a new `KSA` value for `Source Monitor` is required to be set.

## Functions
- Fixed `clip.search()` now working when highlighting multiple words
- Fixed `settingsGUI()` not properly visually tracking if the user changed the `Is Beta Version?` checkbox
    - Now accepts parameter `sendOnFailure` to determine what keys to send on fallback
- Added `clipStorage {` - a class of functions designed to store/send strings
- `keys.allWait()` will now properly handle when the activation hotkey is multiple modifiers (ie <kbd>^!f::</kbd>)
- `getHotkeys()` will now return `false` in the event that two individual hotkeys cannot be determined
- `ffmpeg.__getChannels()` => `ffmpeg.__getAudioStream()`
    - Will now return the entire Map instead of just the `channels` property
    - Now accepts parameter `stream` to manually choose which stream of the file to check
- `generateAdobeShortcut()` will now return `false` if the intended file directory does not exist. This is to stop the function generating dead shortcuts if the user has the wrong version selected

`startup {`
- Fixed `updatePackages()` throwing if a package manager isn't installed
- `adobeVerOverride()` will now show the user the currently selected Adobe versions. This functionality can be toggled in `settingsGUI()`

`switchTo {`
- `Premiere()` & `Photoshop()` now accept parameter `switchBetween` to determine whether you wish for the function to cycle between the main/beta versions of the program if they are both open
- `__adobeSwitch()` & `AE()` will now alert the user using `Notify {` if there is an error attempting to run the desired shortcut
- `adobeProject()` will now better handle activating the correct window when multiple windows with the same name exist

`prem {`
- Added `dismissWarning()`
- Added `dragSourceMon()`
- Added `flattenAndColour()`
- Fixed `__remoteFunc()` spamming logs on success
- `wheelEditPoint()` now sends `ksa.shuttleStop` before proceeding with the rest of the function
- `numpad.gain()` now needs to be activated with <kbd>NumpadSub</kbd>/<kbd>NumpadAdd</kbd>
    - Can now alternatively adjust a clip's `level` by pressing <kbd>NumpadMult</kbd> after hotkey activation  
    
> [!Important]
> The user will need to follow the instructions at the top of this changelog to make use of this new feature as it requires adjusted functions.

`rbuttonPrem {`  
- `movePlayhead()`
    - Fixed function always sending <kbd>RButton</kbd> on fallback even if it wasn't the activation key
    - Uses new function `dismissWarning()` to automatically close any warning windows that appear to stop the function from highlighting the incorrect panel and sending inputs to the wrong place  
    *(This was mostly to deal with a bug in the then current beta build of Premiere that would spam you with audio IO error windows constantly)*

## PremiereRemote
- Added `sourceMonName()`
    - Required adding `getProjectItem()` to `PremierePro.14.0.d.ts`
- Added `setBarsAndTone()`

## Other Changes
- Added `resetTimecode.ahk`
- Added `revealInExplorer.ahk`
- `pcTimerShutdown.ahk` can now optionally schedule a `Sleep` instead
> [!Note]
> This feature is only available if the user downloads `PSTools` from Microsoft and places the contents of that package in their `A_WinDir \System32\` folder. This is a limitation of windows as there is no clean way to schedule a sleep without this tool.

`Premiere_UIA.ahk`
- Fixed `__setNewVal()` locking up the user's inputs if it attempts to fire before a project is opened
- Will now additionally check for the `Source Monitor`

`KSA`
- Added `sourceMonitor`
- Added `modifyStartTime`
- Added `revealExplorer`