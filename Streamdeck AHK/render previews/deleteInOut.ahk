; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\WM>
; }
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
if WinExist(ptf.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, ptf.MainScriptName ".ahk")
prem.Previews("delete", KSA.premDelPrevInOut)