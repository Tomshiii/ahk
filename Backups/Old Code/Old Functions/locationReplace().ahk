/**
 * Within my scripts I have a few hard coded references to the directory location I have these scripts. That however would be useless to another user who places them in another location.
 *
 * To combat this scenario, this function on script startup will check the working directory and change all instances of MY hard coded dir to the users current working directory.
 *
 * This script will take note of the users A_WorkingDir and store it in `A_MyDocuments \tomshi\settings.ini` and will check it every launch to ensure location variables are always updated and accurate
*/
locationReplace() {
    if isReload()
        return
    tool.Wait()
    checkDir := this.UserSettings.working_dir
    if checkDir = A_WorkingDir
        return

    funcTray := "'" A_ThisFunc "()" "'" A_Space
    found := false
    tomshiOrUser := "t"
    loop files, A_WorkingDir "\*.ahk", "R"
        {
            if A_LoopFileName = "switchTo.ahk" || A_LoopFileName = "GUIs.ahk" || A_LoopFileName = "Startup.ahk"
                continue
            read := FileRead(A_LoopFileFullPath)
            if InStr(read, "E:\Github\ahk", 1)
                {
                    found := true
                    break
                }
        }
    if found = false
        {
            loop files, A_WorkingDir "\*.ahk", "R"
                {
                    if A_LoopFileName = "switchTo.ahk" || A_LoopFileName = "GUIs.ahk" || A_LoopFileName = "Startup.ahk"
                        continue
                    read := FileRead(A_LoopFileFullPath)
                    if InStr(read, checkDir, 1)
                        {
                            found := true
                            tomshiOrUser := "u"
                            break
                        }
                }
        }
    if found = false
        return
    tool.tray({text: funcTray "is attempting to replace references to installation directory with user installation directory:`n" A_WorkingDir, options: 17}, 2000)
    SetTimer((*) => tool.tray({text: funcTray "has finished attempting to replace references to the installation directory.`nDouble check " "'" "location :=" "'" " variables to sanity check", options: 17}, 2000), -2000)
    if tomshiOrUser = "t"
        dir := "E:\Github\ahk"
    else if tomshiOrUser = "u"
        dir := checkDir
    loop files, A_WorkingDir "\*.ahk", "R"
        {
            if A_LoopFileName = "switchTo.ahk" || A_LoopFileName = "GUIs.ahk" || A_LoopFileName = "Startup.ahk"
                continue
            read := FileRead(A_LoopFileFullPath)
            if InStr(read, dir, 1)
                {
                    read2 := StrReplace(read, dir, A_WorkingDir)
                    FileDelete(A_LoopFileFullPath)
                    FileAppend(read2, A_LoopFileFullPath)
                }
        }
    this.UserSettings.working_dir := A_WorkingDir
    RunWait(A_ScriptFullPath)
}