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
        ExitApp()
    checklist := findFile "\checklist.ini"
    ;MsgBox(findFile "`n" checklist)
    logs := findFile "\checklist_logs.txt"
    path := findFile
    if !FileExist(checklist)
        generateINI(checklist)
}