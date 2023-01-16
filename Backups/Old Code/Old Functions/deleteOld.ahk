/**
 * This function was designed to transition an install of my scripts from before I had `settings.ini` => a version that does.
 */
deleteOld(&ADOBE, &WORK, &UPDATE, &FC, &TOOLS) {
    if DirExist(A_MyDocuments "\tomshi\adobe")
        {
            try {
                loop files, A_MyDocuments "\tomshi\adobe\*.*"
                    checkAdobe := A_LoopFileName
            }
            if IsSet(checkAdobe)
                ADOBE := checkAdobe
            DirDelete(A_MyDocuments "\tomshi\adobe", 1)
        }
    if DirExist(A_MyDocuments "\tomshi\location")
        {
            try {
                WORK := FileRead(A_MyDocuments "\tomshi\location\workingDir")
            }
            if WORK != ""
                {
                    UPDATE := IniRead(WORK "\Support Files\ignore.ini", "ignore", "ignore", "true")
                    if UPDATE = "no"
                        UPDATE := "true"
                    else UPDATE := "false"
                    if FileExist(WORK "\Support Files\ignore.ini")
                        FileDelete(WORK "\Support Files\ignore.ini")
                }
            DirDelete(A_MyDocuments "\tomshi\location", 1)
        }
    if FileExist(A_MyDocuments "\tomshi\autosave.ini")
        {
            TOOLS := IniRead(A_MyDocuments "\tomshi\autosave.ini", "tooltip", "tooltip", "true")
            FileDelete(A_MyDocuments "\tomshi\autosave.ini")
        }
    if FileExist(A_MyDocuments "\tomshi\first")
        {
            FC := "true"
            FileDelete(A_MyDocuments "\tomshi\first")
        }
}