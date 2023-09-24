> This list is mainly for tasks I intend on completing before the next release, or in upcoming minor releases and is only meant to remind me to do certain little things. For any more major/breaking planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page

# Fixes

## Functions
- [x] qmk keyboard funcs on first use sometimes still swapping to other sequence
- [x] prev/next keyframe sometimes swapping sequences
- [ ] cut repeat code in `prem {` and turn using UIA strings and determining panel positions into a function, maybe have it optionally return values or just return them as an obj

## autosave.ahk
- [ ] autosave saving sometimes causes changing of sequence (clicking RButton at the same time?)
- [ ] often alerts the user it can't determine window if a save makes an attempt when prem isn't active window (ie, another window like discord)
	- might not specifically be related to determining the original window, the error is reached in a catch statement that also includes code like attempting to restart playback. Will require more thorough testing
-[x] make whatever function it is that "backs up" project files not store only 1 instance of the project file - ~~maybe make it user setable (default to something high since every 5min is quite frequent and if it only stores the last hour or so it's not overly useful)~~

## adobe fullscreen check.ahk
- [ ] causes cut on timeline if activates when RButton held down
***

# Additions

## Functions
- [ ] make function in addition to `prem.thumbscroll()` that moves the timeline to the left until released
	- [ ] maybe make a third func to completely reset the playhead to the left and have `prem.thumbscroll()` optionally call it if it hits the end of the timeline

## General
- [ ] make screenshot script (launch from streamdeck? might not be possible to track val) for each of boys, track in class, if 0 ask for starting val (or continue from highest number in folder), ask main script for current val, increment, then name that file and continue
- [ ] make `reset` section of `settingsGUI()` two checkboxes instead and move them below the exit section, then move the exit section up