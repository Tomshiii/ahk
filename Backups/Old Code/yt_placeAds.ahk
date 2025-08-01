#Requires AutoHotkey v2
#Include <Functions\delaySI>
#Include <Classes\block>
#Include <Other\UIA\UIA>

#HotIf WinActive("ahk_exe chrome.exe")

titles := Map("Channel dashboard - YouTube Studio - Google Chrome", true, "Video monetization - YouTube Studio - Google Chrome", true, "Channel content - YouTube Studio - Google Chrome", true)
__howMany(UIAElement, amount) {
    newEl := UIAElement.FindElement({Name: "Skip forward 10 seconds", LocalizedType: "button", AutomationId: "skip-forward-10"})
    loop amount {
        newEl.ControlClick()
    }
    sleep 50
    UIAElement.FindElement({Name:"Play", matchmode:"Substring"}).ControlClick()
}

F1::
{
    currTitle := WinGetTitle("A")
    if titles.has(currTitle) {
        chromeEl := UIA.ElementFromHandle(currTitle " ahk_exe chrome.exe")
        __howMany(chromeEl, 3)
    }
}
F2::
{
    currTitle := WinGetTitle("A")
    if titles.has(currTitle) {
        chromeEl := UIA.ElementFromHandle(currTitle " ahk_exe chrome.exe")
        __howMany(chromeEl, 9)
    }
}
F3::
{
    currTitle := WinGetTitle("A")
    if titles.has(currTitle) {
        chromeEl := UIA.ElementFromHandle(currTitle " ahk_exe chrome.exe")
        __howMany(chromeEl, 15)
    }
}

`:: {
    currTitle := WinGetTitle("A")
    if titles.has(currTitle) {
        chromeEl := UIA.ElementFromHandle(currTitle " ahk_exe chrome.exe")
        try chromeEl.FindElement({Name:"Insert ad slot"}).ControlClick()
        try chromeEl.FindElement({Type: "50000 (Button)", Name: "Play", LocalizedType: "button", AutomationId: "play-button"}).SetFocus()
    }
}