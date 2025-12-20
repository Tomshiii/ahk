; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
; }

SetWorkingDir(A_ScriptDir)
RunWait("replacePremRemote.ahk")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk")