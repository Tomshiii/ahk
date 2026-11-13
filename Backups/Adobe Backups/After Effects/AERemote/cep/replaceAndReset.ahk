; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
; }

SplitPath(A_LineFile,, &cepDir)
SetWorkingDir(cepDir)
RunWait("closeAERemote.ahk")
RunWait(cepDir "\replaceAERemote.ahk 0")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\resetNPM.ahk 1 0 AERemote")
RunWait(ptf.rootDir "\Streamdeck AHK\PremiereRemote\openAERemote.ahk")