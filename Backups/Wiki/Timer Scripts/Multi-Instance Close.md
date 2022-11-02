During debugging of scripts or even just during expected use, sometimes an extra instance of any given script can pop open. Having two instances of a script open can cause weird effects and unexpected behaviour.

You may think to yourself "Well, just use `#SingleInstance Force` right?". Wrong. That alone isn't enough, especially if you're using the `reload` command. Scripts can still slip through the cracks.

`Multi-Instance Close.ahk` creates a constantly running timer that creates a list of all active `ahk_class AutoHotkey` windows and checks to see if there are multiples in that list, if there are, it will close one of those instances.

**This script will ignore `checklist.ahk`*