#SingleInstance Force

;//! this script is mostly designed for my own workflow and isn't really built out with an incredible amount of logic.
;//! it is designed to swap the L/R channel on a single track stereo file.
;//! attempting to use this script on anything else will either produce unintended results or will simply not function at all
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\settings>
#Include <Classes\ptf>
#Include <Classes\block>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Classes\WM>
#Include <Classes\Editors\Premiere>
; }

if !WinActive(prem.winTitle)
    return

clipWinTitle := "Modify Clip"
coord.s()
origCoords := obj.MousePos()
block.On()

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
UserSettings := UserPref()
if WinExist(UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")

if prem.__checkTimelineValues() = true {
    sleep 100
    if !prem.__waitForTimeline(3)
        return
}
if !WinActive(clipWinTitle) {
    SendInput(ksa.audioChannels)
    if !WinWait(clipWinTitle,, 3) {
        block.Off()
        errorLog(Error("Timed out waiting for window", -1),, 1)
        return
    }
    sleep 150
}

clipWin := obj.WinPos(clipWinTitle)
__searchChannel(&x, &y) => ImageSearch(&x, &y, clipWin.x, clipWin.y + 100, clipWin.x + 200, clipWin.y + 300, "*2 " ptf.Premiere "channel1.png")
if !__searchChannel(&x, &y) {
    sleep 150
    if !__searchChannel(&x, &y) {
        block.Off()
        errorLog(TargetError("Couldn't find channel 1.", -1),, 1)
        return
    }
}

left  := ImageSearch(&checkX, &checkY, x, y - 50, x + 200, y + 50, "*2 " ptf.Premiere "L_unchecked.png")
if left = 1 {
    coords := {x: checkX, y: checkY}
}
right := ImageSearch(&checkX, &checkY, x, y - 50, x + 200, y + 50, "*2 " ptf.Premiere "R_unchecked.png")
if right = 1 {
    coords := {x: checkX, y: checkY}
}

;// if the file isn't dual channel it might not have two checkboxes and thus `coords` won't be set
if !IsSet(coords) || !coords {
    block.Off()
    tool.Cust("Checkbox not found")
    return
}

which := (left = 1) ? "L_unchecked.png" : "R_unchecked.png"
Click(Format("{} {}", coords.x+10, coords.y+30))

if !ImageSearch(&okX, &okY, clipWin.x, (clipWin.y + clipWin.height) - 150, clipWin.x + clipWin.width, clipWin.y + clipWin.height, "*2 " ptf.Premiere "channels_ok.png") {
    block.Off()
    errorLog(TargetError("Couldn't find OK button.", -1),, 1)
    return
}
MouseMove(okX, okY, 1)
SendInput("{Click}")
MouseMove(origCoords.x, origCoords.y, 2)
block.Off()