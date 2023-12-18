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
- [x] make `switchTo.adobeProject()` copy path to clipboard on double press
- [ ] make script for prem to quickly select audio in/out selection
- [x] discord style F1/F2 functionality for slack
- [x] discord style capslock functionality for slack
- [x] makes `nexteditpoint` script check effect controls window for `0x454545` (selected property) if anything is selected, <kbd>Ctrl + Click</kbd> it
- [ ] make functions for prem/ae so when I try to zoom in/out on preview monitor (or reset view) it focuses that window first so it actually works
- [x] make extract audio scripts operate on all files by combining command
- [ ] make update script for `choco` packages
	- make it check that choco is installed before continuing with `cmd.result("choco")`
	- maybe make it opt in as it requires cmd windows to linger on the screen for a while
	- `cmd.result("choco list")` to get current installed versions
	- can maybe use `cmd.run(true, false, true, "choco upgrade all --yes")`
```
_ Chocolatey:ChocolateyUpgradeCommand - Noop Mode _
chocolatey v2.2.2 is the latest version available based on your source(s).
chocolatey-compatibility.extension v1.0.0 is the latest version available based on your source(s).
chocolatey-core.extension v1.4.0 is the latest version available based on your source(s).
chocolatey-windowsupdate.extension v1.0.5 is the latest version available based on your source(s).
ffmpeg v6.1.0 is the latest version available based on your source(s).

You have imagemagick.app v7.1.1.1500 installed. Version 7.1.1.2200 is available based on your source(s).
KB2919355 v1.0.20160915 is the latest version available based on your source(s).
KB2919442 v1.0.20160915 is the latest version available based on your source(s).
KB2999226 v1.0.20181019 is the latest version available based on your source(s).
KB3033929 v1.0.5 is the latest version available based on your source(s).
KB3035131 v1.0.3 is the latest version available based on your source(s).

You have mkvtoolnix v79.0.0 installed. Version 81.0.0 is available based on your source(s).

You have python v3.12.0 installed. Version 3.12.1 is available based on your source(s).

You have python3 v3.12.0 installed. Version 3.12.1 is available based on your source(s).
python312 v3.12.0 is the latest version available based on your source(s).

You have vcredist140 v14.36.32532 installed. Version 14.38.33130 is available based on your source(s).
vcredist2010 v10.0.40219.32503 is the latest version available based on your source(s).
vcredist2015 v14.0.24215.20170201 is the latest version available based on your source(s).
yt-dlp v2023.11.16 is the latest version available based on your source(s).

Chocolatey can upgrade 5/19 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

Can upgrade:
 - imagemagick.app v7.1.1.2200
 - mkvtoolnix v81.0.0
 - python v3.12.1
 - python3 v3.12.1
 - vcredist140 v14.38.33130
```

## General
- [ ] make `reset` section of `settingsGUI()` two checkboxes instead and move them below the exit section, then move the exit section up
- [ ] create a detailed wiki page just on installation. include screenshots/gifs
- [ ] add script to automatically convert a path in the clipboard from .mp3 => .wav or visa versa
- [ ] make release script do a backup of all adobe stuff
- [ ] add an additional set of crop scripts to render as prores instead, or provide the user with an option on run with a dropdown or something to let them choose prores/h264
***

# > Cleanup
- [ ] make `tiktok project.ahk` use a class to clean up the spaghetti code