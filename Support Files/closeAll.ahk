#SingleInstance Force
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\reset.ahk
#Include Classes\pause.ahk
#Include Classes\winExt.ahk
#Include Classes\WM.ahk
#Include Other\Notify\Notify.ahk

Critical()
Notify.DestroyAll()
try incChecklist := A_Args[1]
try ignore := A_Args[2]

if !Notify.Exist("reloadAllAlert")
    Notify.Show(, 'All active ahk scripts are being CLOSED', 'C:\Windows\System32\imageres.dll|icon237', 'Windows Startup',, 'pos=TL dur=5 bc=0x330D0D bdr=Maroon iw=24 maxW=400 tag=closeAllAlert')
    ; notifyExt.showIfNotExist("closeAllAlert",, 'All active ahk scripts are being CLOSED', 'C:\Windows\System32\imageres.dll|icon237', 'Windows Startup',, 'pos=TL dur=5 bc=0x330D0D bdr=Maroon iw=24 maxW=400') ;// don't use func here now that Core Functionality.ahk calls the notify gui otherwise it instantly closes
resetter := reset(false)
coreFuncTitle   := "Core Functionality.ahk ahk_class AutoHotkey"
coreFuncHWND    := winExt.ExistRegex(coreFuncTitle,, resetter.ignoreString,, true)
activeWindows   := resetter.__getList()
; logger := Log()
for v in activeWindows {
    if !getInfo := resetter.__parseInfo(v, incChecklist ?? false)
        continue
    if IsSet(ignore) && getInfo.scriptName = ignore
        continue
    if WM.timerScripts.Has(getInfo.scriptName) {
        justName := StrReplace(getInfo.scriptName, ".ahk", "",,, 1)
        justName := StrReplace(justName, A_Space, "_")
        ; logger.Append(getInfo.scriptName "|" justName "_stop" "|" WM.timerScripts[getInfo.scriptName])
        try WM.Send_WM_COPYDATA(justName "_stop," WM.timerScripts[getInfo.scriptName], getInfo.scriptName, -1, false)
    }
    if getInfo.scriptName = "HotkeylessAHK.ahk" {
        resetter.__resetHotkeyless(true)
        continue
    }
    ; logger.Append("closing: " getInfo.scriptName)
    ; try pause.pause(StrReplace(getInfo.scriptName, ".ahk", ""), false)
    ProcessClose(getInfo.PID)
    if !checkPID := winExt.ExistRegex(getInfo.PID,, resetter.ignoreString,, true)
        continue
    try WinClose(checkPID)
}
Critical("Off")
__checkClose(hwnd, title) {
    if hwnd {
        ProcessClose(hwnd)
        hwnd := winExt.ExistRegex(title,, resetter.ignoreString,, true)
        if hwnd {
            try WinClose(hwnd)
            if hwnd := winExt.ExistRegex(title,, resetter.ignoreString,, true)
                try winExt.CloseRegex(hwnd,,,, true)
        }
    }
}
__checkClose(coreFuncHWND, coreFuncTitle)

SetTimer(destroyAlert, -3000)
destroyAlert(*) {
    if Notify.Exist("closeAllAlert")
        try Notify.Destroy("closeAllAlert")
}