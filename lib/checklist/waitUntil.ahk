; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\winGet>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Functions\detect>
#Include <Functions\errorLog>
; }

SetTimer(waitUntil, -1000)
#SingleInstance Force
SetWorkingDir(ptf.lib)
TraySetIcon(ptf.Icons "\waitUntil.png")
waitUntil()
{
    detect()
    if !WinExist("Adobe Premiere Pro") && !WinExist(editors.AE.winTitle)
        {
            if WinExist("checklist.ahk",, browser.vscode.winTitle)
                ProcessClose(WinGetPID("checklist.ahk",, browser.vscode.winTitle))
            SetTimer(, 0)
            return
        }
    dashLocationAgain := unset
    aeLocationAgain := unset
    if WinExist("Adobe Premiere Pro")
        {
            winget.PremName(&Namepremdash, &titlecheck, &savecheck) ;first we grab some information about the premiere pro window
            if !IsSet(titlecheck) ;we ensure the title variable has been assigned before proceeding forward
                {
                    block.Off()
                    errorLog(UnsetError("Variable wasn't assigned a value.", -1, titlecheck),, 1)
                    SetTimer(, -1000)
                }
            dashLocationAgain := InStr(Namepremdash, "-")
            if dashLocationAgain = 0
                dashLocationAgain := unset
        }
    else if WinExist(editors.AE.winTitle)
        {
            aeCheckagain := WinGetTitle(editors.AE.winTitle)
            if !IsSet(aeCheckagain) ;we ensure the title variable has been assigned before proceeding forward
                {
                    block.Off()
                    errorLog(UnsetError("Variable wasn't assigned a value", -1, aeCheckagain),, 1)
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
    if WinExist("checklist.ahk",, browser.vscode.winTitle)
        ProcessClose(WinGetPID("checklist.ahk",, browser.vscode.winTitle))
    Run(ptf["checklist"])
    SetTimer(, 0)
}