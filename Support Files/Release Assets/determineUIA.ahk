#SingleInstance Force
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\CLSID_Objs.ahk
#Include Classes\Editors\Premiere.ahk
; #Include Classes\Editors\Premiere_UIA.ahk
#Include Classes\Editors\Premiere_UIA.ahk

if !WinExist(prem.winTitle)
    return

loop {
    premName := WinGet.PremName()
    if !IsSet(premName) || !IsObject(premName) || !premName.titleCheck {
        Sleep(1500)
        continue
    }
    break
}

premUIA_Values().setObjs()