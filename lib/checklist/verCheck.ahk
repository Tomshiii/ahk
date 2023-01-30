; { \\ #Includes
#Include <checklist\trythenDel>
; }

localVer := IniRead(checklist, "Info", "ver")
problemDir("v2.6")

;if the in use ini file is lower than the current version, it will generate a new one
if VerCompare(version, localVer) > 0
    {
        SplitPath(checklist,, &dir)
        if !DirExist(dir "\backup")
            DirCreate(dir "\backup")
        if FileExist(checklist)
            FileCopy(checklist, dir "\backup\checklist.ini", 1)
        if FileExist(logs)
            FileCopy(logs, dir "\backup\checklist_logs.txt", 1)
        trythenDel("version")
    }