> This list is mainly for tasks I intend on completing before the next release, or in upcoming minor releases and is only meant to remind me to do certain little things. For any more major/breaking planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page

## Functions
- [x] open adobe proj func not working if any explorer window already open
- [x] right clicking in the prem program monitor appears to hang everything. ~~is it bc of right click prem?~~ nope. just premiere being dumb
- [ ] wait for timeline focus func seems to cause endless loop failing to focus the timeline
- [ ] qmk keyboard funcs on first use sometimes still swapping to other sequence
- [ ] prev/next keyframe sometimes swapping sequences
- [ ] make function in addition to `prem.thumbscroll()` that moves the timeline to the left until released
	- [ ] maybe make a third func to completely reset the playhead to the left and have `prem.thumbscroll()` optionally call it if it hits the end of the timeline 

## autosave.ahk
- [ ] autosave saving sometimes causes changing of sequence (clicking RButton at the same time?)
- [ ] often alerts the user it can't determine window if a save makes an attempt when prem isn't active window (ie, another window like discord)

## General
- [x] fix margin button swapping between open sequences
- [x] mention this todo in the readme/wiki
- [x] add GUI similar to `trimGUI.ahk` but for reencoding
- [x] make `quickHotstring()` automatically add the entry in its alphabetical spot
- [ ] make screenshot script (launch from streamdeck?) for each of boys, track in class, if 0 ask for starting val, ask main script for current val, increment, then name that file and continue

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
