# <> Release 2.15 - 
> [!Important]
> If the user has previously used `PremiereRemote` with my scripts this version will require them to copy `..\Backups\Adobe Backups\Premiere\PremiereRemote\typings\PremierePro.14.0.d.ts` -> `A_AppData "\Adobe\CEP\extensions\PremiereRemote\typings\` or they may run into issues with missing functions. Installing `PremiereRemote` from this release onwards will not require anything extra from the user however.

> [!Caution]
> If the user uses `UIA` with `Premiere` functions, a new `KSA` value for `Source Monitor` is required to be set.

## Functions
- Fixed `startup.updatePackages()` throwing if a package manager isn't installed
- Fixed `clip.search()` now working when highlighting multiple words
- Fixed `settingsGUI()` not properly visually tracking if the user changes the `Is Beta Version?` checkbox
- Fixed `rbuttonPrem.movePlayhead()` always sending <kbd>RButton</kbd> on fallback even if it wasn't the activation key
    - Now accepts parameter `sendOnFailure` to determine what keys to send on fallback
- Added `clipStorage {` - a class of functions designed to store/send strings
- `keys.allWait()` will now properly handle when the activation hotkey is multiple modifiers (ie <kbd>^!f::</kbd>)
- `getHotkeys()` will now return `false` in the event that two individual hotkeys cannot be determined
- `startup.adobeVerOverride()` now accepts parameter `showVers` which if set to `true` will show the user the currently selected adobe versions on each script load
- `switchTo.Premiere()` & `switchTo.Photoshop()` now accept parameter `switchBetween` to determine whether you wish for the function to cycle between the main/beta versions of the program if they are both open
- `ffmpeg.__getChannels()` => `ffmpeg.__getAudioStream()`
    - Will now return the entire Map instead of just the `channels` property
    - Now accepts parameter `stream` to manually choose which stream of the file to check

`prem {`
- Added `dismissWarning()`
- Added `dragSourceMon()`
- Added `flattenAndColour()`
- Fixed `__remoteFunc()` spamming logs on success

## PremiereRemote
- Added `sourceMonName()`
    - Required adding `getProjectItem()` to `PremierePro.14.0.d.ts`
- Added `setBarsAndTone()`

## Other Changes
- Added `resetTimecode.ahk`
- `pcTimerShutdown.ahk` can now optionally schedule a `Sleep` instead
> [!Note]
> This feature is only available if the user downloads `PSTools` from Microsoft and places the contents of that package in their `A_WinDir \System32\` folder. This is a limitation of windows as there is no clean way to schedule a sleep without this tool.

`Premiere_UIA.ahk`
- Fixed `__setNewVal()` locking up the user's inputs if it attempts to fire before a project is opened
- Will now additionally check for the `Source Monitor`

`KSA`
- Added `sourceMonitor`
- Added `modifyStartTime`