> This list is mainly for tasks I intend on completing before the next release, or in upcoming minor releases and is only meant to remind me to do certain little things. For any more major/breaking planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page

## Functions
- [ ] wait for timeline focus func seems to cause endless loop failing to focus the timeline
- [ ] qmk keyboard funcs on first use sometimes still swapping to other sequence
- [ ] prev/next keyframe sometimes swapping sequences
- [ ] make function in addition to `prem.thumbscroll()` that moves the timeline to the left until released
	- [ ] maybe make a third func to completely reset the playhead to the left and have `prem.thumbscroll()` optionally call it if it hits the end of the timeline 

## autosave.ahk
- [ ] autosave saving sometimes causes changing of sequence (clicking RButton at the same time?)
- [ ] often alerts the user it can't determine window if a save makes an attempt when prem isn't active window (ie, another window like discord)
- [ ] ![image](https://github.com/Tomshiii/ahk/assets/53557479/b622978c-1310-4323-8ac9-bb049a317fb9)

## adobe fullscreen check.ahk
- [ ] causes cut on timeline if activates when RButton held down

## General
- [ ] make screenshot script (launch from streamdeck? might not be possible to track val) for each of boys, track in class, if 0 ask for starting val (or continue from highest number in folder), ask main script for current val, increment, then name that file and continue
- [x] change replace with ae comp script to check if AE is open, if it isn't ask if you wanted to create a new ae proj or open an old one
- [ ] make `discord {` `disableAutoReplyPing` adjustable via `settingsGUI()`
- [x] separate generating adobe symvers into own script instead of being forced to run symlink script