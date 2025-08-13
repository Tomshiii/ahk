; { \\ #Includes
#Include <Classes\ptf>
; }

SetWorkingDir(A_ScriptDir)
RunWait("replacePremRemote.ahk")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk")