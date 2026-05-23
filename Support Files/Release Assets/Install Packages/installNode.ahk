#Include downloadNode.ahk

path := A_WorkingDir "\nodejs.msi"
downloadNode(path)
RunWait('msiexec.exe /i "' . path . '" /qn /norestart',, "Hide")
sleep 100
FileDelete(path)
ExitApp()