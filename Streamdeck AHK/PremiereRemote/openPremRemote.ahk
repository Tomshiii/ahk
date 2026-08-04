; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Functions\delaySI.ahk
#Include Classes\winGet.ahk
#Include Classes\switchTo.ahk
; }

;// this script just reopens an extension window within premiere as anytime you change
;// the `index` file for `PremiereRemote` you need to reset the window within premiere

if !WinExist(Editors.Premiere.winTitle)
    return
if !WinActive(Editors.Premiere.winTitle)
    switchTo.Premiere()
; delaySI(25, "!w", "{Down 2}", "{Right}", "{Up 3}", "{Enter}")
n := WinGet.PremName()
try MenuSelect(n.winTitle,, "Window", "Extensions", "PremiereRemote")
catch {
    return
}