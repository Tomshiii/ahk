haltChecklist()
{
    Run(ptf.lib "\checklist\waitUntil.ahk")
    detect()
    if WinExist("checklist.ahk",, browser.vscode.winTitle)
        ProcessClose(WinGetPID("checklist.ahk",, browser.vscode.winTitle))
}