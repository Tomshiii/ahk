> This list is mainly for tasks I intend on completing before the next release and is only meant to remind me to do certain little things. For any more major planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page

## Functions
- [ ] open adobe proj func not working if any explorer window already open
- [ ] right clicking in the prem program monitor appears to hang everything. is it bc of right click prem?
- [ ] autosave saving sometimes causes changing of sequence (clicking RButton at the same time?)

## General
- [ ] fix margin button swapping between open sequences
- [ ] mention this todo in the readme/wiki
- [x] add GUI similar to `trimGUI.ahk` but for reencoding

`adobe fullscreen check`
- [x] throws when prem not responding
```
Error: (5) Access is denied.
	---- S:\Program Files\User\Documents\AutoHotkey\Lib\Classes\winget.ahk
	404: }
	411: {
▶   413: proc := WinGetProcessName(hwnd)
	414: class := WinGetClass(hwnd)
	416: If proc = "explorer.exe" && this.explorerIgnoreMap.Has(class)
```
- [ ] causes cut on timeline if activates when RButton held down