; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
#Include Classes\errorLog.ahk
; }

;// moves the playhead 1s using PremiereRemote
;// will move forward by default or backwards if the user holds LCtrl

if !WinActive(prem.winTitle)
    return
if prem.didWiggle != false {
    amount := 2000-(A_TickCount-prem.didWiggle)
    (amount > 0) ? sleep(amount) : ""
}
if GetKeyState("LCtrl", "P")
    prem.__remoteUXP("custom/movePlayhead",, "subtract=true", "seconds=1")
else
    prem.__remoteUXP("custom/movePlayhead",, "subtract=false", "seconds=1")