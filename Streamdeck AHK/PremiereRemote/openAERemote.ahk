; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Functions\delaySI.ahk
#Include Classes\winGet.ahk
#Include Classes\switchTo.ahk
; }

;// this script just reopens an extension window within ae as anytime you change
;// the `index` file for `AERemote` you need to reset the window within premiere

if !WinExist(Editors.ae.winTitle)
    return
if !WinActive(Editors.ae.winTitle)
    switchTo.AE()
; delaySI(25, "!w", "{Down 2}", "{Right}", "{Up 3}", "{Enter}")
n := WinGet.AEName()
try MenuSelect(n.winTitle,, "Window", "Extensions", "AERemote")
catch {
    return
}