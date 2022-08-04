;this script is to replace all checklists in use after an update. If you have run `My Scripts.ahk` and it has successfully changed the working directory of my scripts, then this script should step you through the process of it changing the path variables down below. If I at any point make changes to the amount of data entered into the log files, and you replace an old checklist.ahk file with that newer version, you may encounter runtime errors as that log data will not exist unless you input it manually
location := "E:\comms\"
parentFolder := "E:\Github\ahk"

if not DirExist(location)
    {
        dirReplace := DirSelect("::{20d04fe0-3aea-1069-a2d8-08002b30309d}", 3, "Please select the desired folder this script will search for checklist.ahk files")
        if dirReplace = ""
            return
        read := FileRead(A_ScriptFullPath)
        foundpos := InStr(read, ':= "',,,1)
        endpos := InStr(read, '"',, foundpos, 2)
        end := endpos - foundpos - 2
        dir := SubStr(read, foundpos + 4, end - 2)
        newRead := StrReplace(read, dir, dirReplace "\",,, 1)
        if not DirExist(A_Temp "\tomshi")
            DirCreate(A_Temp "\tomshi")
        FileAppend(newRead, A_Temp "\tomshi\" A_ScriptName)
        FileMove(A_Temp "\tomshi\" A_ScriptName, A_ScriptDir, 1)
        return
    }

#SingleInstance Force
/* toolCust()
  create a tooltip with any message
  * @param message is what you want the tooltip to say
  * @param timeout is how many ms you want the tooltip to last
  */
toolCust(message, timeout)
{
    ToolTip(message)
    SetTimer(timeouttime, - timeout)
    timeouttime()
    {
        ToolTip("")
    }
}

localVer(location)
{
    verString := FileRead(location)
    foundpos := InStr(verString, 'v2',,,2)
    endpos := InStr(verString, ';', , foundpos, 1)
    end := endpos - foundpos - 5
    version := SubStr(verString, foundpos, end)
    return version
}

latestVer := localVer(parentFolder "\checklist.ahk")
replace := ""

if FileExist(A_ScriptDir "\replaceChecklist_log.txt")
    FileDelete(A_ScriptDir "\replaceChecklist_log.txt")
loop files, location "*.ahk", "R"
    {
        if A_LoopFileName = "checklist.ahk"
            {
                inUseVer := localVer(A_LoopFileFullPath)
                ;now we check for problem versions
                if replace = ""
                    {
                        if VerCompare(latestVer, "v2.3") >= 0 && VerCompare(inUseVer, "v2.3") < 0 ;this is to alert the user of a change I made to the accompanying .ini file
                            {
                                warning := MsgBox("WARNING`nLater versions of ``checklist.ahk`` use incompatible .ini files. If you wish, this script can remove all old versions of the .ini files and the checklist script will automatically create a new .ini file when it is next run.`nDoing so however will remove all saved checkboxes as well as the saved time passed.`n`nIf you're okay with losing this data: Select Yes`nIf you wish for these .ini files to be left alone and manually replaced by you: Select No", "WARNING", "4 48 256 4096")
                                if warning = "Yes"
                                    replace := "Yes"
                                if warning = "No"
                                    replace := "No"
                            }
                    }
                if VerCompare(latestVer, inUseVer) <= 0
                    {
                        try {
                            FileAppend(A_Mon "-" A_DD "_" A_LoopFileFullPath " -- was the same or newer than the local version of checklist.ahk and was not replaced`n", A_ScriptDir "\replaceChecklist_log.txt")
                        }
                        continue
                    }
                try {
                    FileAppend(A_Mon "-" A_DD "_" A_LoopFileFullPath " -- replaced " inUseVer " with // " latestVer "`n", A_ScriptDir "\replaceChecklist_log.txt")
                    FileDelete(A_LoopFileFullPath)
                    FileCopy(parentFolder "\checklist.ahk", A_LoopFilePath, 1)
                } catch as e {
                    toolCust("Encountered an error with " A_LoopFileFullPath, "1000")
                    FileAppend("Encountered an error with " A_LoopFileFullPath "`n", A_ScriptDir "\replaceChecklist_log.txt")
                }
                if replace = "Yes"
                    {
                        if FileExist(A_LoopFileDir "\checkbox.ini")
                            {
                                FileDelete(A_LoopFileDir "\checkbox.ini")
                                FileAppend(A_Mon "-" A_DD "_" A_LoopFileDir "\checkbox.ini -- removed`n", A_ScriptDir "\replaceChecklist_log.txt")
                            }
                        if FileExist(A_LoopFileDir "\checklist.ini")
                            {
                                FileDelete(A_LoopFileDir "\checklist.ini")
                                FileAppend(A_Mon "-" A_DD "_" A_LoopFileDir "\checklist.ini -- removed`n", A_ScriptDir "\replaceChecklist_log.txt")
                            }
                    }
                }
        else
            continue
        ToolTip("")
    }