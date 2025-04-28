# <> Release 2.15.x - 

> [!Caution]
> If the user uses `PremiereRemote` and isn't doing a clean install, this release requires the user to run `..\Backups\Adobe Backups\Premiere\PremiereRemote\replacePremRemote.ahk` as some functions have been updated.

## Functions
- ✅ Fixed `startup.generate()` not always setting `MainScriptName`

⚠️ `prem {`
- ✏️ Added `setScale()`
- ✏️ Added `rippleCut()`
- ✅ Fixed `save()` not actually getting a return value for the current sequence
- `__remoteFunc()` will now return boolean `true`/`false` instead of a string
- `numpadGain()`
    - Will now inform the user if it times out
    - Can now be cancelled by pressing <kbd>Escape</kbd>