haltChecklist()
{
    Run(A_WorkingDir "\lib\checklist\waitUntil.ahk")
    detect()
    if WinExist("checklist.ahk",, "Visual Studio Code")
        ProcessClose(WinGetPID("checklist.ahk",, "Visual Studio Code"))
}