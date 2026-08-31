; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
#Include Classes\switchTo.ahk
#Include Classes\winGet.ahk
; %}

if !WinExist(prem.winTitle)
    return
if !WinExist(prem.winTitle)
    return
if !WinActive(prem.winTitle)
    switchTo.Premiere()

n := WinGet.PremName()
try MenuSelect(n.winTitle,, "Window", "Extensions", "PremiereRemote")
catch {
    return
}

sleep 100
SendInput(ksa.prem.closePanel)