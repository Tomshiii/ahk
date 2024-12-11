#Requires AutoHotkey v2
#Include <Functions\delaySI>
#Include <Classes\block>

#HotIf WinActive("ahk_exe chrome.exe")

F1::
{
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ")  {
        block.on()
        delaySI(16, "{Lbutton}", "{Lbutton}", "{Lbutton}")
        block.off()
    }
}
F2::
{
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ") {
        block.on()
        delaySI(16, "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}")
        block.off()
    }
}
F3::
{
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ") {
        block.on()
        delaySI(16, "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}", "{Lbutton}")
        block.off()
    }
}