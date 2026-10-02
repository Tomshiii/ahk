; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\CLSID_Objs.ahk
; }

SetWorkingDir(A_ScriptDir)
RunWait("closePremRemote.ahk")
RunWait("replacePremRemote.ahk false")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\openPremRemote.ahk")
try CLSID_Objs.writeProp("prem", "__cepFuncMap", false)