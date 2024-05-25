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

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
UserSettings := UserPref()
if WinExist(UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")

prem.swapChannels()