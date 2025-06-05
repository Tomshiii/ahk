; { \\ #Includes
#Include <Classes\clip>
#Include <Functions\FormatWeekRange>
; }

^+c::clip.search("", "chrome.exe")
^+t::SendText(FormatWeekRange())
^+y::SendText(FormatWeekRange("M", 1))

^+d::
{
    default := "
    (
    ### Alex
    - [ ]
    ### Eduardo
    - [ ]
    ### James
    - [ ] general checkin. where are you at?
    ### Everyone
    - [ ]

    ### Other
    - [ ] Any questions, queries, or things you want me to chase?
    )"
    storeClip := clip.clear()
    sleep 50
    A_Clipboard := default
    if !ClipWait(2) {
        clip.returnClip(storeClip.storedClip)
        return
    }
    SendInput("^v")
    clip.returnClip(storeClip.storedClip)
}