> This list is mainly for tasks I intend on completing before the next release, or in upcoming minor releases and is only meant to remind me to do certain little things. For any more major/breaking planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page
***

# > Fixes

## Functions
- [x] `ytdlp().download()` or `ytdlp().handleDownload()` not properly dealing with twitch links

## autosave.ahk
- [ ] autosave saving sometimes causes changing of sequence ~~(clicking RButton at the same time?)~~ - definitely happening regardless
- [ ] often alerts the user it can't determine window if a save makes an attempt when prem isn't active window (ie, another window like discord)
	- might not specifically be related to determining the original window, the error is reached in a catch statement that also includes code like attempting to restart playback. Will require more thorough testing

## adobe fullscreen check.ahk
- [ ] causes cut on timeline if activates when RButton held down
***

# > Additions

## Functions
- [ ] make function in addition to `prem.thumbscroll()` that moves the timeline to the left until released
	- [ ] maybe make a third func to completely reset the playhead to the left and have `prem.thumbscroll()` optionally call it if it hits the end of the timeline
- [ ] make `switchTo.adobeProject()` copy path to clipboard on double press
- [ ] make script for prem to quickly select audio in/out selection

## General
- [ ] make `reset` section of `settingsGUI()` two checkboxes instead and move them below the exit section, then move the exit section up
***

# > Cleanup
- [ ] make `tiktok project.ahk` use a class to clean up the spaghetti code