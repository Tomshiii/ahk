; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\clip.ahk
#Include Functions\FormatWeekRange.ahk
#Include Functions\FormatWeekDay.ahk
; }

^+c::clip.search("", "chrome.exe")
^+t::SendInput(A_YYYY "-" A_MM "-" A_DD)
^1::SendText(FormatWeekRange())
^2::SendText(FormatWeekRange(, 1))
^3::SendText(FormatWeekDay())
^4::SendText(FormatWeekDay(,, 1))

^+d::
{
    default := "
    (
    ### Alex
    - [ ]
    ### Eduardo
    - [ ]
    ### Everyone
    - [ ] make sure we're uploading shorts if we haven't already

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