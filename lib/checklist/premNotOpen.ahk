/**
 * This function handles what thhe script should do if Premiere Pro isn't currently open
 * @param {var} checklist is a variable we pass back to the main script as it allows us to update the variable
 * @param {var} logs is a variable we pass back to the main script as it allows us to update the variable
 * @param {var} path is a variable we pass back to the main script as it allows us to update the variable
 */
premNotOpen(&checklist, &logs, &path)
{
    findFile := FileSelect("D 3",, "Select commission folder")
    if findFile = ""
        {
            if WaitTrack != 0
                global WaitTrack := 0
            detect()
            if WinExist("checklist.ahk",, browser.vscode.winTitle)
                ProcessClose(WinGetPID("checklist.ahk",, browser.vscode.winTitle))
        }
    checklist := findFile "\checklist.ini"
    ;MsgBox(findFile "`n" checklist)
    logs := findFile "\checklist_logs.txt"
    path := findFile
    if !FileExist(checklist)
        generateINI(checklist)
}