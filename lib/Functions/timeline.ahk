; { \\ #Includes
#Include <Classes\coord>
#Include <Classes\block>
; }

/**
 * A weaker version of the Premiere_RightClick.ahk script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
 * @param {Integer} timeline in this function defines the y pixel value of the top bar in your video editor that allows you to click it to drag along the timeline
 * @param {Integer} x1 is the furthest left pixel value of the timeline that will work with your cursor warping up to grab it
 * @param {Integer} x2 is the furthest right pixel value of the timeline that will work with your cursor warping up to grab it
 * @param {Integer} y1 is just below the bar that your mouse will be warping to, this way your mouse doesn't try doing things when you're doing other stuff above the timeline
 */
timeline(timeline, x1, x2, y1) {
    coord.w()
    MouseGetPos(&xpos, &ypos)
    if !(xpos > x1 && xpos < x2) && !(ypos > y1) ;this function will only trigger if your cursor is within the timeline. This ofcourse can break if you accidently move around your workspace
        return
    block.On()
    MouseMove(xpos, timeline) ;this will warp the mouse to the top part of your timeline defined by &timeline
    SendInput("{Click Down}")
    MouseMove(xpos, ypos)
    block.Off()
    KeyWait(A_ThisHotkey)
    SendInput("{Click Up}")
}