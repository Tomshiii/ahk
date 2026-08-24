; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\After Effects.ahk
#Include Classes\switchTo.ahk
#Include Classes\winGet.ahk
; %}

if !WinExist(ae.winTitle)
    return
if !WinExist(ae.winTitle)
    return
if !WinActive(ae.winTitle)
    switchTo.AE()

n := WinGet.AEName()
try MenuSelect(n.winTitle,, "Window", "Extensions", "AERemote")
catch {
    return
}