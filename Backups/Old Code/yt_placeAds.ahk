#Requires AutoHotkey v2
#Include <Functions\delaySI>
#Include <Classes\block>
#Include <Other\UIA\UIA>

#HotIf WinActive("ahk_exe chrome.exe")

title1 := "Video monetization - YouTube Studio - Google Chrome"
title2 := "Channel content - YouTube Studio - Google Chrome"
__howMany(UIAElement, amount) {
    newEl := UIAElement.FindElement({A:"skip-forward-10"})
    loop amount {
        newEl.ControlClick()
    }
    sleep 50
    UIAElement.FindElement({Name:"Play", matchmode:"Substring"}).ControlClick()
}

F1::
{
    currTitle := WinGetTitle("A")
    if currTitle == title1 || currTitle == title2 {
        title := (currTitle == title1) ? title1 : title2
        chromeEl := UIA.ElementFromHandle(title " ahk_exe chrome.exe")
        __howMany(chromeEl, 3)
    }
}
F2::
{
    currTitle := WinGetTitle("A")
    if currTitle == title1 || currTitle == title2 {
        title := (currTitle == title1) ? title1 : title2
        chromeEl := UIA.ElementFromHandle(title " ahk_exe chrome.exe")
        __howMany(chromeEl, 9)
    }
}
F3::
{
    currTitle := WinGetTitle("A")
    if currTitle == title1 || currTitle == title2 {
        title := (currTitle == title1) ? title1 : title2
        chromeEl := UIA.ElementFromHandle(title " ahk_exe chrome.exe")
        __howMany(chromeEl, 15)
    }
}

`:: {
    currTitle := WinGetTitle("A")
    if currTitle == title1 || currTitle == title2 {
        title := (currTitle == title1) ? title1 : title2
        chromeEl := UIA.ElementFromHandle(title " ahk_exe chrome.exe")
        try chromeEl.FindElement({Name:"Insert ad slot"}).ControlClick()
    }
}