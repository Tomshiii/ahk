; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
; }

SetWorkingDir(A_ScriptDir)
RunWait("closeAERemote.ahk")
SplitPath(A_WorkingDir,, &cepDir)
SplitPath(cepDir,, &aeDir)
SplitPath(aeDir,, &adobeDir)
premDir := adobeDir "\Premiere\PremiereRemote\cep"
RunWait(premDir "\replacePremRemote.ahk 0 AERemote")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk 1 0 AERemote")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\openAERemote.ahk")