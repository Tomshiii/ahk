/**
     * This function is here to cut repeat code across a few scripts, its purpose is to find the `checklist.ahk` file for the open Premiere/After Effects project. It's used in QMK.ahk and autosave.ahk
     */
openChecklist()
{
    tool.Wait()
    try {
        if WinExist("Adobe Premiere Pro")
            {
                Name := WinGetTitle("Adobe Premiere Pro")
                titlecheck := InStr(Name, "Adobe Premiere Pro " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe Premiere Pro [Year]"
                if titlecheck = ""
                    {
                        block.Off()
                        tool.Cust("``titlecheck`` variable wasn't assigned a value")
                        errorLog(, A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                        return
                    }
            }
        else if WinExist("Adobe After Effects")
            {
                Name := WinGetTitle("Adobe After Effects")
                titlecheck := InStr(Name, "Adobe After Effects " A_Year " -") ;change this year value to your own year. | we add the " -" to accomodate a window that is literally just called "Adobe After Effects [Year]"
                if titlecheck = ""
                    {
                        block.Off()
                        tool.Cust("``afterFXTitle`` variable wasn't assigned a value")
                        errorLog(, A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                        return
                    }
            }
        dashLocation := InStr(Name, "-")
        length := StrLen(Name) - dashLocation
    }
    if !IsSet(titlecheck) || IsSet(afterFXTitle)
        {
            block.Off()
            tool.Cust("``titlecheck/afterFXTitle`` variable wasn't assigned a value")
            errorLog(, A_ThisFunc "()", "``titlecheck/afterFXTitle`` variable wasn't assigned a value", A_LineFile, A_LineNumber)
            return
        }
    if !titlecheck
        {
            tool.Cust("You're on a part of Premiere that won't contain the project path", 2000)
            return
        }
    entirePath := SubStr(name, dashLocation + "2", length)
    finalSlash := InStr(entirePath, "\",, -1)
    path := SubStr(entirePath, 1, finalSlash - "1")
    SplitPath path, &name
    if WinExist("Checklist - " name)
        {
            WinMove(-345, -191,,, "Checklist - " name) ;move it back into place incase I've moved it
            tool.Cust("You already have this checklist open")
            errorLog(, A_ThisHotkey, "You already have this checklist open", A_LineFile, A_LineNumber)
            return
        }
    if FileExist(path "\checklist.ahk")
        Run(path "\checklist.ahk")
    else
        {
            try {
                FileCopy(ptf["checklist"], path)
                Run(path "\checklist.ahk")
            } catch as e {
                tool.Cust("File not found")
            }
        }
}