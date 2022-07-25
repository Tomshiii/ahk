;this script is to replace all checklists in use after an update. It will require you to change the below `location :=` variable for the directory you use for projects as well as your parent directory for this repo. If I at any point make changes to the amount of data entered into the log files, and you replace an old checklist.ahk file with that newer version, you may encounter runtime errors as that log data will not exist unless you input it manually
location := "E:\comms\"
parentFolder := "E:\Github\ahk"

#SingleInstance Force
/* toolCust()
  create a tooltip with any message
  * @param message is what you want the tooltip to say
  * @param timeout is how many ms you want the tooltip to last
  */
toolCust(message, timeout)
{
    ToolTip(%&message%)
    SetTimer(timeouttime, - %&timeout%)
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

if FileExist(A_ScriptDir "\replaceChecklist_log.txt")
    FileDelete(A_ScriptDir "\replaceChecklist_log.txt")
if FileExist(A_ScriptDir "\logUpdatesNeeded.txt")
    FileDelete(A_ScriptDir "\logUpdatesNeeded.txt")
loop files, location "*.ahk", "R"
    {  
        if A_LoopFileName = "checklist.ahk"
            {
                inUseVer := localVer(A_LoopFileFullPath)
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
            }
        else
            continue
        ToolTip("")
    }