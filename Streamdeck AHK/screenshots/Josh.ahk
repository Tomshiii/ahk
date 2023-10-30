; { \\ #Includes
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\wm>
#Include <Classes\obj>
; }

onMsgObj := ObjBindMethod(WM, "__parseMessageResponse")
OnMessage(0x004A, onMsgObj.Bind())  ; 0x004A is WM_COPYDATA

detect()
currentName := obj.SplitPath(A_ScriptName)
if WinExist(ptf.MainScriptName ".ahk")
    WM.Send_WM_COPYDATA("Premiere_sc" currentName.NameNoExt "," A_ScriptName, ptf.MainScriptName ".ahk")
prem.screenShot(currentName.NameNoExt)