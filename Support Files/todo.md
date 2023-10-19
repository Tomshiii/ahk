> This list is mainly for tasks I intend on completing before the next release, or in upcoming minor releases and is only meant to remind me to do certain little things. For any more major/breaking planned changes, reference the [Upcoming Changes](https://github.com/users/Tomshiii/projects/1) page

# Fixes

## Functions
- [ ] cut repeat code in `prem {` and turn using UIA strings and determining panel positions into a function, maybe have it optionally return values or just return them as an obj
- [x] if switchTo.prem/ae determines a shortcut doesn't exist for the file, attempt to create it and try again

## autosave.ahk
- [ ] autosave saving sometimes causes changing of sequence ~~(clicking RButton at the same time?)~~ - definitely happening regardless
- [ ] often alerts the user it can't determine window if a save makes an attempt when prem isn't active window (ie, another window like discord)
	- might not specifically be related to determining the original window, the error is reached in a catch statement that also includes code like attempting to restart playback. Will require more thorough testing
- [ ] add option to enable/disable checking mouse movement before saving - might be too annoying for some

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
- [ ] make streamdeck script to crop input video in half to split cam/gameplay videos.
	- use a gui to select the file & choose whether cam is on the left or right.
		- add option to use bitrate instead of crf
	- maybe extend off `reencode` gui to offer the same options?
	```
	;// crop video - 1
	ffmpeg -i "[INPUT FILEPATH]" -c:v libx264 -preset veryfast -b:v 30000k -filter:v "crop=in_w/2:in_h:0:0" -c:a copy "[OUTPUT FILEPATH]"

	;// crop video - 2
	ffmpeg -i "[INPUT FILEPATH]" -c:v libx264 -preset veryfast -b:v 30000k -filter:v "crop=in_w/2:in_h:in_w/2:0" -c:a copy "[OUTPUT FILEPATH]"

	;// c3
	ffmpeg -i "[INPUT FILEPATH]" -filter_complex "[0]crop=iw/2:ih:0:0[left];[0]crop=iw/2:ih:ow:0[right]" -map "[left]" "[LEFT OUTPUT FILEPATH]" -map "[right]" "[RIGHT OUTPUT FILEPATH]"
	; for %f in (*.mkv) do ffmpeg -i "%f" -c:v libx264 -preset veryfast -b:v 30000k -c:a copy -filter_complex "[0]crop=iw/2:ih:0:0[left];[0]crop=iw/2:ih:ow:0[right]" -map "[left]" "%~nf_c1.mp4" -map "[right]" -c:v libx264 -preset veryfast -b:v 30000k -c:a copy "%~nf_c2.mp4"
	```
	- maybe have it build array of filepaths in dir, then do a `for p in arr` runwait c1, runwait c2, continue
		- trying to run two cmd process at the same time would likely be time beneficial but correctly waiting for them both to close before continuing might be challenging
-


ffmpeg -i -c:v libx264 -preset veryfast -b:v 30000k -filter:v "crop=in_w/2:in_h:1920:0" -c:a copy "E:\comms\the boys\gaming\1. Escape from Wormtown\josh_c2_1920.mp4"
ffmpeg -i "E:\comms\the boys\gaming\1. Escape from Wormtown\josh.mkv" -c:v libx264 -preset veryfast -b:v 30000k -filter:v "crop=in_w/2:in_h:1921:0" -c:a copy "E:\comms\the boys\gaming\1. Escape from Wormtown\josh_c2_1921.mp4"

