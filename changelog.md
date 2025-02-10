# <> Release 2.15.x - 
A bug in the third party lib [`WinEvent`](<https://github.com/Descolada/AHK-v2-libraries/issues/15>) was causing `prem.dissmissWarning()` to never fire when used in `Premiere_RightClick.ahk`. This issue has now been recitified and is once again working as expected.

## Functions
- `startup.libUpdateCheck()` now checks for `Notify Creator.ahk` updates
- Fixed `prem.dismissWarning()` utilising incorrect coords

## Other Changes
- `backupProj.ahk` now alerts the user once it begins the backup process
- `[aud/vid][Part/Select].ahk` scripts now better manage the clipboard to allow the user to copy/paste before the actual download process begins