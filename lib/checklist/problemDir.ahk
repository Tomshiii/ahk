/**
 * This function is called anytime the user needs to be alerted about a checklist.ini change that will break the script
 * @param {String} version is the version passed in that is going to be compared against the current version
 */
problemDir(version)
{
    if VerCompare(localVer, version) < 0
        {
            SplitPath(checklist,, &dir)
            if !DirExist(dir "\backup")
                DirCreate(dir "\backup")
            if FileExist(checklist)
                {
                    FileCopy(checklist, dir "\backup\checklist.ini", 1)
                    FileDelete(checklist)
                }
            if FileExist(logs)
                {
                    FileCopy(logs, dir "\backup\checklist_logs.txt", 1)
                    FileDelete(logs)
                }
            MsgBox("checklist.ini files lower than " version " are no longer compatible`nYour current .ini & log files have been backed up in the project folder but a new .ini file has been generated")
            generateINI(checklist)
        }
}