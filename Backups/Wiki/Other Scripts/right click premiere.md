The initial idea to do this was thought up by [TaranVH](https://github.com/TaranVH/2nd-keyboard) a previous editor for LTT. I have since *heavily* edited it to be more useful for myself.
***
The most important/frequent thing you do while video editing is moving around on the timeline. Ideally you want this to be fast, functional and most of all, accurate. This script aims to do all three.

The biggest bottleneck with timeline navigation is always manipulating the playhead (that's the blue line that runs vertical on the screen to signify what frame of footage you're looking at). By default in Premiere, the only ways to move the playhead are;

- Moving the mouse to it, being in the exact right position so the cursor will change and then you can grab it with a left click on the mouse.
- Moving the mouse to the top of the timeline where it shows a lined timecode and left clicking on it to move the playhead to the cursor position.

These methods are fine, but they're slow and awkward - they require too much movement from the user before anything can happen. It might not seem like that big of a deal by itself but overtime these wasted movements add up.

This script takes advantage of a wonderful hotkey within Premiere Pro, `move playhead to cursor`. This hotkey is an absolute game changer and is the only reason this script is so powerful. With it we can create a loop that occurs while the user holds down another button (`RButton` by default) that will warp the playhead to the cursor position at the click of a mouse button! awesome!

But that wasn't enough for me, I wanted to manipulate playback even further. I often watch footage in 2x speed to work faster so letting go of `RButton` to then either press `Space + l` to get to 2x speed or double tap `l`  was moving my hands around way too much, way too often and wasting a tonne of time (as well as making them sore). So with this in mind I added functionality to this script so that;

- If the user presses the `LButton` while holding `RButton` and the loop is active, once the user lets go of `RButton` the script would automatically restart playback on the timeline
- If the user presses `XButton2` while holding `RButton` and the loop is active, once the user lets go of `RButton` the script would automatically restart playback on the timeline at 2x speed

Awesome!

As I have premiere set to not follow the playhead during playback (if the playhead moves off my screen during playback, the timeline WON'T warp to it to make sure it's always on screen) I also added functionality to check to see if the playhead is on the screen before starting the warp. If the playhead IS on the screen, it will pause playback first, if the playhead ISN'T on screen, it won't. This stops the timeline from warping all over the place after attempting to move the playhead.