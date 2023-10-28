> This list is mainly for tasks I intend on completing before the next release, or in upcoming minor releases and is only meant to remind me to do certain little things. For any more major/breaking planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page
***

# > Fixes

## Functions
- [x] if switchTo.prem/ae determines a shortcut doesn't exist for the file, attempt to create it and try again
- [x] RCLick Prem scripts seem to not be firing towards the right of the timeline (all versions (v22.3.1, v23.5, v24.0)) - might be grabbing coords incorrectly

## autosave.ahk
- [ ] autosave saving sometimes causes changing of sequence ~~(clicking RButton at the same time?)~~ - definitely happening regardless
- [ ] often alerts the user it can't determine window if a save makes an attempt when prem isn't active window (ie, another window like discord)
	- might not specifically be related to determining the original window, the error is reached in a catch statement that also includes code like attempting to restart playback. Will require more thorough testing
- [x] add option to enable/disable checking mouse movement before saving - might be too annoying for some

## adobe fullscreen check.ahk
- [ ] causes cut on timeline if activates when RButton held down
***

# > Additions

## Functions
- [ ] make function in addition to `prem.thumbscroll()` that moves the timeline to the left until released
	- [ ] maybe make a third func to completely reset the playhead to the left and have `prem.thumbscroll()` optionally call it if it hits the end of the timeline

## General
- [ ] make screenshot script (launch from streamdeck? might not be possible to track val) for each of boys, track in class, if 0 ask for starting val (or continue from highest number in folder), ask main script for current val, increment, then name that file and continue
- [ ] make `reset` section of `settingsGUI()` two checkboxes instead and move them below the exit section, then move the exit section up
- [x] make streamdeck script to crop input video in half to split cam/gameplay videos.
	- use a gui to select the file & choose whether cam is on the left or right.
	- maybe extend off `reencode` gui to offer the same options?
		- add option to use bitrate instead of crf
	- maybe have it build array of filepaths in dir, then do a `for p in arr` runwait c1, runwait c2, continue
		- trying to run two cmd process at the same time would likely be time beneficial but correctly waiting for them both to close before continuing might be challenging
***

# > Cleanup
- [ ] cut repeat code in `prem {` and turn using UIA strings and determining panel positions into a function, maybe have it optionally return values or just return them as an obj
- [ ] make `tiktok project.ahk` use a class to clean up the spaghetti code