; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Editors\Premiere>
#Include <Classes\WM>
; }
onMsgObj := ObjBindMethod(prem, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
if WinExist("My Scripts.ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, "My Scripts.ahk")
prem.Previews("delete", KSA.premDelPrevInOut)