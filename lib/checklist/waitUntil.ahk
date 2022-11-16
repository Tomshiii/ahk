SetTimer(waitUntil, -1000)
#SingleInstance Force
SetWorkingDir(ptf.lib)
#Include <\KSA\Keyboard Shortcut Adjustments> ;this is only added to prevent errors
#Include <\Functions\Windows> ;this is only added to prevent errors
#Include <\Functions\switchTo> ;this is only added to prevent errors
#Include <\Functions\Startup> ;this is only added to prevent errors
#Include <\Functions\General> ;this is added because we need it
TraySetIcon(ptf.Icons "\waitUntil.png")
waitUntil()
{
    detect()
    if !WinExist("Adobe Premiere Pro") && !WinExist("ahk_exe AfterFX.exe")
        {
            if WinExist("checklist.ahk",, "Visual Studio Code")
                ProcessClose(WinGetPID("checklist.ahk",, "Visual Studio Code"))
            SetTimer(, 0)
            return
        }
    dashLocationAgain := unset
    aeLocationAgain := unset
    if WinExist("Adobe Premiere Pro")
        {
            getPremName(&Namepremdash, &titlecheck, &savecheck) ;first we grab some information about the premiere pro window
            if !IsSet(titlecheck) ;we ensure the title variable has been assigned before proceeding forward
                {
                    block.Off()
                    tool.Cust("``titlecheck`` variable wasn't assigned a value")
                    errorLog(, A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                    SetTimer(, -1000)
                }
            dashLocationAgain := InStr(Namepremdash, "-")
            if dashLocationAgain = 0
                dashLocationAgain := unset
        }
    else if WinExist("ahk_exe AfterFX.exe")
        {
            aeCheckagain := WinGetTitle("ahk_exe AfterFX.exe")
            if !IsSet(aeCheckagain) ;we ensure the title variable has been assigned before proceeding forward
                {
                    block.Off()
                    tool.Cust("``aeCheckagain`` variable wasn't assigned a value")
                    errorLog(, A_ThisFunc "()", "Variable wasn't assigned a value", A_LineFile, A_LineNumber)
                    SetTimer(, -1000)
                }
            if !InStr(aeCheckagain, ":`\")
                {
                    try {
                        aeCheckagain := WinGetTitle("Adobe After Effects")
                    }
                    if !InStr(aeCheckagain, ":`\")
                        aeLocationAgain := unset
                    else
                        aeLocationAgain := InStr(aeCheckagain, ":`\")
                }
        }
    if !IsSet(dashLocationAgain) && !IsSet(aeLocationAgain)
        {
            SetTimer(, -1000)
            return
        }
    if WinExist("checklist.ahk",, "Visual Studio Code")
        ProcessClose(WinGetPID("checklist.ahk",, "Visual Studio Code"))
    Run(A_WorkingDir "\checklist.ahk")
    SetTimer(, 0)
}