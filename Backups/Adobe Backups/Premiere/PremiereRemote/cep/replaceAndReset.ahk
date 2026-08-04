; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
; }

SetWorkingDir(A_ScriptDir)
RunWait("closePremRemote.ahk")
RunWait("replacePremRemote.ahk false")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\openPremRemote.ahk")