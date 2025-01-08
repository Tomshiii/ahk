#Include <Classes\Editors\Premiere>

;// moves the playhead 1s using PremiereRemote
;// will move forward by default or backwards if the user holds LCtrl

if !WinActive(prem.winTitle)
    return

if !prem.__checkPremRemoteDir('movePlayhead') {
    errorLog(Error("This script requires PremiereRemote", -1),, true)
    return
}

if GetKeyState("LCtrl", "P")
    prem.__remoteFunc("movePlayhead",, "subtract=true", "seconds=1")
else
    prem.__remoteFunc("movePlayhead",, "subtract=false", "seconds=1")