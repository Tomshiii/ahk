audioDrag(folder, sfxName) ;(old | uses media browser instead of a project bin)
{
    SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
    ;KeyWait(A_PriorKey) ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
    block.On()
    coord.s()
    MouseGetPos(&xpos, &ypos)
    SendInput(mediaBrowser) ;highlights the media browser ~ check the keyboard shortcut ini file to adjust hotkeys
    sleep 10
    if ImageSearch(&sfx, &sfy, mbX1, mbY1, mbX2, mbY2, "*2 " ptf.Premiere folder ".png") ;searches for my sfx folder in the media browser to see if it's already selected or not
        {
            MouseMove(sfx, sfy) ;if it isn't selected, this will move to it then click it
            SendInput("{Click}")
            MouseMove(xpos, ypos)
            sleep 100
            goto next
        }
    else if ImageSearch(&sfx, &sfy, mbX1, mbY1, mbX2, mbY2, "*2 " ptf.Premiere folder "2.png") ;if it is selected, this will see it, then move on
        goto next
    else ;if everything fails, this else will trigger
        {
            block.Off()
            tool.Cust("sfx folder",, 1)
            MouseMove(xpos, ypos)
            return
        }
    next:
    SendInput(findBox) ;adjust this in the keyboard shortcuts ini file
    coord.c()
    SendInput("^a" "+{BackSpace}") ;deletes anything that might be in the search box
    SendInput(sfxName)
    sleep 150
    if ImageSearch(&vlx, &vly, mbX1, mbY1, mbX2, mbY2, "*2 " ptf.Premiere "vlc.png") ;searches for the vlc icon to grab the track
        {
            MouseMove(vlx, vly)
            SendInput("{Click Down}")
        }
    else
        {
            block.Off()
            tool.Cust("vlc image", 2000, 1) ;useful tooltip to help you debug when it can't find what it's looking for
            MouseMove(xpos, ypos)
            return
        }
    MouseMove(xpos, ypos)
    SendInput("{Click Up}")
    SendInput(mediaBrowser)
    SendInput(findBox)
    SendInput("^a" "+{BackSpace}" "{Enter}")
    sleep 50
    SendInput(timelineWindow)
    block.Off()
}