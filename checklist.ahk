#SingleInstance Force
#Requires AutoHotkey v2.0

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Functions\floorDecimal>
#Include <Functions\errorLog>
#Include <Functions\detect>
#Include <GUIs\tomshiBasic>
; <checklist funcs> ;everything in <lib\checklist\> is needed for this script
;but these are just the ones that can be defined anywhere
#Include <checklist\timers>
#Include <checklist\generateIni>
#Include <checklist\premNotOpen>
#Include <checklist\problemDir>
#Include <checklist\trythenDel>
#Include <checklist\timers>
#Include <checklist\log>
#Include <checklist\getPath>
#Include <checklist\haltChecklist>
#Include <checklist\checkSettings>
#Include <checklist\msgButton>
; }

TraySetIcon(ptf.Icons "\checklist.ico")

closeWaitUntil() ;checks to see if `waitUntil.ahk` is open and closes it if it is

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
version := "v2.11-rc.1"
;todays date
today := A_YYYY "_" A_MM "_" A_DD

;THIS SCRIPT --->>
;DO NOT RELOAD THIS SCRIPT WITHOUT FIRST STOPPING THE TIMER - PRESSING THE `X` IS FINE BUT RELOADING FROM THE FILE MIGHT CAUSE IT TO CLOSE WITHOUT WRITING THE ELAPSED TIME

;SET THE AMOUNT OF MINUTES YOU WANT THE REMINDER TIMER TO WAIT HERE
minutes := 1
global ms := minutes * 60000
;SET THE AMOUNT OF MINUTES YOU WANT INBETWEEN EACH TIME THE SCRIPT LOGS HOW MUCH TIME HAS PASSED (purely for backup purposes)
minutes2 := 10
global ms10 := minutes2 * 60000
checklist := ""
global WaitTrack := 0
global morethannine := unset
global morethan11 := unset

if DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)" ;if the checklist is reloaded, we don't want it to automatically attempt to grab the title of the currently open premiere project - this allows us to open/create new projects while premiere is open
    {
        premNotOpen(&checklist, &logs, &path)
        if WinExist("Select commission folder")
            ExitApp()
        if WinExist("Wait or Continue?")
            ExitApp()
    }
else
    {
        if !WinExist(Editors.Premiere.winTitle) && !WinExist(editors.AE.winTitle)
            {
                premNotOpen(&checklist, &logs, &path)
                if WinExist("Select commission folder")
                    WinWaitClose("Select commission folder")
                if WinExist("Wait or Continue?")
                    ExitApp()
                goto end
            }
        dashLocation := unset
        dashLocationAE := unset
        if WinExist(Editors.Premiere.winTitle)
            {
                winget.PremName(&Nameprem, &titlecheck, &savecheck) ;first we grab some information about the premiere pro window
                if !IsSet(titlecheck) ;we ensure the title variable has been assigned before proceeding forward
                    {
                        block.Off()
                        tool.Cust("``titlecheck`` variable wasn't assigned a value")
                        errorLog(UnsetError("Variable hasn't been assigned a value.", -1, titlecheck), A_ThisFunc "()")
                        premNotOpen(&checklist, &logs, &path)
                        if WinExist("Select commission folder")
                            WinWaitClose("Select commission folder")
                        if WinExist("Wait or Continue?")
                            WinWaitClose("Wait or Continue?")
                    }
                dashLocation := InStr(Nameprem, "-")
                if dashLocation = 0
                    dashLocation := unset
            }
        else if WinExist(editors.AE.winTitle)
            {
                aeCheck := WinGetTitle(editors.AE.winTitle)
                if !IsSet(aeCheck) ;we ensure the title variable has been assigned before proceeding forward
                    {
                        block.Off()
                        tool.Cust("``aeCheck`` variable wasn't assigned a value")
                        errorLog(UnsetError("Variable hasn't been assigned a value.", -1, aeCheck), A_ThisFunc "()")
                        premNotOpen(&checklist, &logs, &path)
                        if WinExist("Select commission folder")
                            WinWaitClose("Select commission folder")
                        if WinExist("Wait or Continue?")
                            WinWaitClose("Wait or Continue?")
                        goto end
                    }
                if !InStr(aeCheck, ":`\")
                    {
                        try {
                            aeCheck := WinGetTitle("Adobe After Effects")
                        }
                        if !InStr(aeCheck, ":`\")
                            dashLocationAE := unset
                        else
                            dashLocationAE := InStr(aeCheck, ":`\")
                    }
                else
                    dashLocationAE := InStr(aeCheck, ":`\")
                /* MsgBox("aeCheck " aeCheck)
                if IsSet(dashLocationAE)
                    MsgBox("dash " dashLocationAE) */
            }
        if !IsSet(dashLocation) && !IsSet(dashLocationAE)
            {
                detect()
                if FileExist(ptf["settings"]) ;checks to see if the user wants to always wait until they open a project
                    {
                        waitCheck := IniRead(ptf["settings"], "Settings", "checklist Wait", "false")
                        if waitCheck = "true"
                            {
                                WaitTrack := 1
                                tool.Wait()
                                haltChecklist()
                            }
                    }
                if WaitTrack = 0
                    {
                        tool.Wait()
                        WaitTrack := 1
                        SetTimer(change_msgButton, 50)
                        Result := MsgBox("You haven't opened a project yet, do you want ``" A_ScriptName "`` to wait until you have?`nOr would you like to select the checklist file now?", "Wait or Continue?", "4 32 4096")
                        if Result = "Yes"
                            haltChecklist()
                        else
                            {
                                premNotOpen(&checklist, &logs, &path)
                                if WinExist("Select commission folder")
                                    WinWaitClose("Select commission folder")
                            }
                    }
            }
        if IsSet(dashLocation)
            getPath(Nameprem, dashLocation, &checklist, &logs, &path)
        else if IsSet(dashLocationAE)
            {
                getaeDash := InStr(aeCheck, "-")
                getPath(aeCheck, getaeDash, &checklist, &logs, &path)
            }
        end:
    }

;// setting default settings for GUI
global globalCheckTool := checkTooltips()
global globalDarkTool := checkDark()

#Include <checklist\verCheck>

;getting the title
SplitPath(path, &name)

;grabbing hour information from ini file
getTime := IniRead(checklist, "Info", "time")
timeForLog := Round(getTime / 3600, 3)
if getTime = 0
    timeForLog := "0.000"
;checking for log file
if !FileExist(logs)
    FileAppend("Initial creation time : " today ", " A_Hour ":" A_Min ":" A_Sec "`n`n{ " today " - " timeForLog "`n", logs)

newDate(&today)

;constructing the GUI
#Include <checklist\contruct>

FileAppend("\\ The checklist was opened : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after opening = " startHoursRounded " -- seconds at opening = " startValue "`n", logs)

if darkToolTrack = 1
    which()
MyGui.OnEvent("Close", ExitFunc.Bind("", ""))
MyGui.Show("AutoSize NoActivate")
MyGui.Move(-345, -191,,) ;I have it set to move onto one of my other monitors, if you notice that you can't see it after opening or it keeps warping to a weird location, this line of code is why
;finish defining GUI
#Include <checklist\close>