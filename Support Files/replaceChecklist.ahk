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
  @param message is what you want the tooltip to say
  @param timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1s
  @param find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 for this variable if you do, or omit it if you don't
  */
toolCust(message, timeout := 1000, find := "")
{
    if find != 1
        messageFind := ""
    else
        messageFind := "Couldn't find "
    ToolTip(messageFind message)
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
                ;ignore backup folders
                if InStr(A_LoopFileDir, "backup", 1)
                    continue
                if InStr(A_LoopFileDir, "backups", 1) ;incase the user creates their own
                    continue
                inUseVer := localVer(A_LoopFileFullPath)
                ;now we check for problem versions
                
                /* newIni()
                 This function will facilitate the creation of new .ini files for new releases of `checklist.ahk`. It will allow me to easily add new .ini values without the user needing to do anything
                 @param boxOrlist is a required variable to due a typo on local versions of `checklist.ahk` below v2.3
                 */
                newIni(boxOrlist)
                {
                    try {
                        FP := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "FirstPass", "0")
                        SP := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "SecondPass", "0")
                        TW := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "TwitchOverlay", "0")
                        YT := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "YoutubeOverlay", "0")
                        TR := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "Transitions", "0")
                        SFX := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "SFX", "0")
                        MU := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "Music", "0")
                        PT := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "Patreon", "0")
                        INTR := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "Intro", "0")
                        TI := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "time", "0")
                        TOOL := IniRead(A_LoopFileDir "\check" boxOrlist ".ini", "Info", "tooltip", "1")
                    }
                    if !DirExist(A_LoopFileDir "\backup")
                        DirCreate(A_LoopFileDir "\backup")
                    if !FileExist(A_LoopFileDir "\backup\check" boxOrlist ".ini")
                        FileCopy(A_LoopFileDir "\check" boxOrlist ".ini", A_LoopFileDir "\backup\check" boxOrlist ".ini")
                    else
                        {
                            static skip := 0
                            if skip = 1
                                {
                                    FileCopy(A_LoopFileDir "\check" boxOrlist ".ini", A_LoopFileDir "\backup\check" boxOrlist ".ini", 1)
                                    return
                                }
                            A_Clipboard := A_LoopFileDir "\backup"
                            SetTimer(changebuttons, 10)
                            check := MsgBox("Backup of checklist.ini already exists in;`n`n" A_LoopFileDir "\backup`n`nWould you like it replaced?`nThe dir has been copied to the clipboard", "Backup?", "3")
                            if check = "No"
                                ExitApp()
                            if check = "Yes"
                                FileCopy(A_LoopFileDir "\check" boxOrlist ".ini", A_LoopFileDir "\backup\check" boxOrlist ".ini", 1)
                            if check = "Cancel"
                                {
                                    skip := 1
                                    FileCopy(A_LoopFileDir "\check" boxOrlist ".ini", A_LoopFileDir "\backup\check" boxOrlist ".ini", 1)
                                    return
                                }

                            changebuttons()
                            {
                                if !WinExist("Backup?")
                                    return  ; Keep waiting.
                                SetTimer(, 0)
                                WinActivate
                                ControlSetText "&Yes", "Button1"
                                ControlSetText "&No", "Button2"
                                ControlSetText "&Yes to All", "Button3"
                            }
                        }
                    FileDelete(A_LoopFileDir "\check" boxOrlist ".ini")
                    FileAppend("[Info]`nFirstPass=" FP "`nSecondPass=" SP "`nTwitchOverlay=" TW "`nYoutubeOverlay=" YT "`nTransitions=" TR "`nSFX=" SFX "`nMusic=" MU "`nPatreon=" PT "`nIntro=" INTR "`ntime=" TI "`ntooltip=" TOOL, A_LoopFileDir "\checklist.ini")
                }
                if VerCompare(latestVer, "v2.3") >= 0 && VerCompare(inUseVer, "v2.3") < 0 ;this is to alert the user of a change I made to the accompanying .ini file in local version v2.3 (or Release v2.5). I changed it from `checkbox.ini` -> `checklist.ini`
                    newIni("box")
                if VerCompare(latestVer, inUseVer) <= 0 ;comment out this block if you've made a small change and want to replace stuff to test without needing to increment the ver number
                    {
                        try {
                            FileAppend(A_Mon "-" A_DD "_" A_LoopFileFullPath " -- was the same or newer than the local version of checklist.ahk and was not replaced`n", A_ScriptDir "\replaceChecklist_log.txt")
                        }
                        continue
                    }
                if VerCompare(latestVer, inUseVer) > 0 ;This check will generate new .ini files anytime there's a new version of `checklist.ahk`. This check will allow me to easily add new ini values
                    {
                        if FileExist(A_LoopFileDir "\checklist.ini")
                            newIni("list")
                    }
                try {
                    FileAppend(A_Mon "-" A_DD "_" A_LoopFileFullPath " -- replaced " inUseVer " with // " latestVer "`n", A_ScriptDir "\replaceChecklist_log.txt")
                    FileDelete(A_LoopFileFullPath)
                    FileCopy(parentFolder "\checklist.ahk", A_LoopFilePath, 1)
                } catch as e {
                    toolCust("Encountered an error with " A_LoopFileFullPath)
                    FileAppend("Encountered an error with " A_LoopFileFullPath "`n", A_ScriptDir "\replaceChecklist_log.txt")
                }
            }
        else
            continue
        ToolTip("")
    }