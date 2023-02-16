; { \\ #Includes
#Include <Functions\detect>
; }

/**
 * This function will run `waitUntil.ahk` and then close `checklist.ahk` if it is open
 */
haltChecklist()
{
    Run(ptf.lib "\checklist\waitUntil.ahk")
    detect()
    if WinExist("checklist.ahk",, "- Visual Studio Code " browser.vscode.winTitle)
        ProcessClose(WinGetPID("checklist.ahk",, "- Visual Studio Code " browser.vscode.winTitle))
}