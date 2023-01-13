/**
 * This function handles what the script should do if Premiere Pro isn't currently open
 * @param {VarRef} checklist is a variable we pass back to the main script as it allows us to update the variable
 * @param {VarRef} logs is a variable we pass back to the main script as it allows us to update the variable
 * @param {VarRef} path is a variable we pass back to the main script as it allows us to update the variable
 */
premNotOpen(&checklist, &logs, &path)
{
    findFile := FileSelect("D 3",, "Select commission folder")
    if findFile = ""
        {
            detect()
            if WinExist("checklist.ahk",, browser.vscode.winTitle)
                ProcessClose(WinGetPID("checklist.ahk",, browser.vscode.winTitle))
        }
    checklist := findFile "\checklist.ini"
    logs := findFile "\checklist_logs.txt"
    path := findFile
    if !FileExist(checklist)
        generateINI(checklist)
}