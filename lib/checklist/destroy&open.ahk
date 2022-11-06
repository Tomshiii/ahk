DetectHiddenWindows(1)
SetTitleMatchMode(2)

if WinExist("checklist.ahk - AutoHotkey")
    WinClose("checklist.ahk - AutoHotkey")
Run("..\..\checklist.ahk")