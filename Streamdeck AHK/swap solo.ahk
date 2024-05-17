; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\settings>
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\WM>
#Include <Classes\obj>
; }

#SingleInstance Force

soloAdjustVal := 79

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
UserSettings := UserPref()
if WinExist(UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
if !prem.__checkTimelineValues()
    prem.__checkTimelineFocus()

premUIA := premUIA_Values()
try premUIAEl := prem.__createUIAelement(false)
if IsSet(premUIAEl)
    premUIAEl.AdobeEl.ElementFromPath(premUIA.timeline).SetFocus()
else
    prem.__checkTimelineFocus()

origPos := obj.MousePos()
tool.Cust("Please press the numpad button corresponding to the track you'd like to solo.`n`nOr press ESC to cancel.", 4.0)
;"{Numpad1}, {Numpad2}, {Numpad3}, {Numpad4}, {Numpad5}, {Numpad6}, {Numpad7}, {Numpad8}, {Numpad9}"
ih := InputHook("L2", "{Escape}, {NumpadEnter}, {Enter}, {Tab}")
ih.Start()
ih.Wait()
if (!IsInteger(ih.Input) && ih.Input != "") || (ih.EndKey = "Escape") {
    tool.Cust("")
    return
}
if ih.Input != 0 && ih.Input != "" {
    if !FileExist(ptf.Premiere "track " ih.input "_1.png") && !FileExist(ptf.Premiere "track " ih.input "_2.png") && !FileExist(ptf.Premiere "track " ih.input "_3.png") {
        tool.Cust("The selected track doesn't have images corresponding to it!`nYou may need to take your own screenshots if you wish to use values that high.", 4.0)
        return
    }
}
coord.client()
loop {
    if !ImageSearch(&x, &y, prem.timelineRawX, prem.timelineRawY, prem.timelineXControl, prem.timelineYControl, "*2 " ptf.Premiere "solo.png")
        break
    Click(Format("{} {}", x, y))
    sleep 100
}
if ih.Input = 0 || ih.Input = "" {
    MouseMove(origPos.x, origPos.y, 2)
    tool.Cust("")
    return
}
if !obj.imgSrchMulti({x1: prem.timelineRawX, y1: prem.timelineRawY, x2: prem.timelineXControl, y2: prem.timelineYControl},, &x, &y
                        , ptf.Premiere "track " ih.input "_1.png", ptf.Premiere "track " ih.input "_2.png", ptf.Premiere "track " ih.input "_3.png") {
    tool.Cust("Couldn't find the location of the desired track", 3.0)
    return
}
if ih.Input > 9
    soloAdjustVal+=10
Click(Format("{} {}", x+soloAdjustVal, y))
MouseMove(origPos.x, origPos.y, 2)
tool.Cust("")