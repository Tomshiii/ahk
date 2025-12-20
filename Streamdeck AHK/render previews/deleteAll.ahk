; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\ptf.ahk
#Include Classes\WM.ahk
; }
onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
UserSettings := UserPref()
if WinExist(UserSettings.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, UserSettings.MainScriptName ".ahk")
prem.deletePreviews(KSA.premDelPrevAll)
