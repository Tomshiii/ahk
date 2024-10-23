# <> Release 2.15 - 
> [!Important]
> If the user has previously used `PremiereRemote` with my scripts this version will require them to copy `..\Backups\Adobe Backups\Premiere\PremiereRemote\typings\PremierePro.14.0.d.ts` -> `A_AppData "\Adobe\CEP\extensions\PremiereRemote\typings\` or they may run into issues with missing functions. Installing `PremiereRemote` from this release onwards will not require anything extra from the user however.

## Functions
- Fixed `startup.updatePackages()` throwing if a package manager isn't installed
- Fixed `clip.search()` now working when highlighting multiple words
- Fixed `settingsGUI()` not properly visually tracking if the user changes the `Is Beta Version?` checkbox
- Fixed `rbuttonPrem.movePlayhead()` always sending `RButton` on fallback even if that wasn't the activation key
    - Now accepts parameter `sendOnFailure` to determine what keys to send on fallback
- `keys.allWait()` will now properly handle when the activation hotkey is multiple modifiers (ie <kbd>^!f::</kbd>)
- `getHotkeys()` will now return `false` in the event that two individual hotkeys cannot be determined

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
- `Premiere_UIA.ahk` will now additionally check for the `Source Monitor`
- `pcTimerShutdown.ahk` can now optionally schedule a `Sleep` instead
> [!Note]
> This feature is only available if the user downloads `PSTools` from Microsoft and places the contents of that package in their `A_WinDir \System32\` folder. This is a limitation of windows as there is no clean way to schedule a sleep without this tool.