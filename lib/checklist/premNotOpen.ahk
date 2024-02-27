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
            if WinExist("checklist.ahk",, "- Visual Studio Code " browser.vscode.winTitle)
                ProcessClose(WinGetPID("checklist.ahk",, "- Visual Studio Code " browser.vscode.winTitle))
        }
    checklist := (FileExist(findFile "\_project files\checklist.ini")) ? findFile "\_project files\checklist.ini" : findFile "\checklist.ini"
    SplitPath(checklist,, &chosenDir)
    logs := chosenDir "\checklist_logs.txt"
    path := chosenDir
    if !FileExist(checklist)
        generateINI(checklist)
}