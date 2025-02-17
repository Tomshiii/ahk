#Requires AutoHotkey v2
#Include <Functions\delaySI>
#Include <Classes\block>
#Include <Other\UIA\UIA>

#HotIf WinActive("ahk_exe chrome.exe")

__howMany(UIAElement, amount) {
    newEl := UIAElement.FindElement({A:"skip-forward-10"})
    loop amount {
        newEl.ControlClick()
    }
        UIAElement.FindElement({Name:"Play", matchmode:"Substring"}).ControlClick()
}

F1::
{
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ")  {
        chromeEl := UIA.ElementFromHandle("Video monetization - YouTube Studio - Google Chrome ahk_exe chrome.exe")
        __howMany(chromeEl, 3)
    }
}
F2::
{
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ") {
        chromeEl := UIA.ElementFromHandle("Video monetization - YouTube Studio - Google Chrome ahk_exe chrome.exe")
        __howMany(chromeEl, 9)
    }
}
F3::
{
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ") {
        chromeEl := UIA.ElementFromHandle("Video monetization - YouTube Studio - Google Chrome ahk_exe chrome.exe")
        __howMany(chromeEl, 15)
    }
}

`:: {
    if InStr(WinGetTitle("A"), "Video monetization - YouTube Studio - ") {
        chromeEl := UIA.ElementFromHandle("Video monetization - YouTube Studio - Google Chrome ahk_exe chrome.exe")
        chromeEl.FindElement({A:"add-ad-break"}).ControlClick()
    }
}