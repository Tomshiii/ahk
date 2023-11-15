#SingleInstance Force
#Requires AutoHotkey v2.0

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\block>
#Include <Classes\errorLog>
#Include <Classes\winget>
#Include <Functions\floorDecimal>
#Include <Functions\detect>
#Include <Functions\isReload>
#Include <Functions\change_msgButton>
#Include <Functions\trayShortcut>
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
; }

TraySetIcon(ptf.Icons "\checklist.ico")
startupTray()

closeWaitUntil() ;checks to see if `waitUntil.ahk` is open and closes it if it is

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
version := "v2.12.10"
;todays date
today := A_YYYY "_" A_MM "_" A_DD

;THIS SCRIPT --->>
;DO NOT RELOAD THIS SCRIPT WITHOUT FIRST STOPPING THE TIMER - PRESSING THE `X` IS FINE BUT RELOADING FROM THE FILE MIGHT CAUSE IT TO CLOSE WITHOUT WRITING THE ELAPSED TIME

checklist := ""
WaitTrack := 0

if isReload() ;if the checklist is reloaded, we don't want it to automatically attempt to grab the title of the currently open premiere project - this allows us to open/create new projects while premiere is open
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
        openProg := WinExist(Editors.Premiere.winTitle) ? winget.PremName(, &titleCheck)
                                                        : winget.AEName(, &titleCheck)
        if !IsSet(titleCheck)
            {
                block.Off()
                errorLog(UnsetError("Variable hasn't been assigned a value.", -1),, 1)
                premNotOpen(&checklist, &logs, &path)
                if WinExist("Select commission folder")
                    WinWaitClose("Select commission folder")
                if WinExist("Wait or Continue?")
                    WinWaitClose("Wait or Continue?")
            }
        if InStr(openProg.winTitle, "Adobe After Effects 20" ptf.AEYearVer, 1, 1, 1) {
            dashLocation := InStr(openProg.winTitle, ":`\") ? InStr(openProg.winTitle, "-") : unset
        }
        else
            dashLocation := InStr(openProg.winTitle, "-")
        if IsSet(dashLocation) && dashLocation = 0
            dashLocation := unset
        if !IsSet(dashLocation)
            {
                detect()
                UserSettings := UserPref()
                settingsFile := UserSettings.SettingsFile
                checklist_wait := UserSettings.checklist_wait
                UserSettings := ""
                if FileExist(settingsFile) ;checks to see if the user wants to always wait until they open a project
                    {
                        if checklist_wait = true
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
                        msgTitle := "Wait or Continue?"
                        SetTimer(change_msgButton.Bind(msgTitle, "Wait", "Select Now"), 50)
                        Result := MsgBox("You haven't opened a project yet, do you want ``" A_ScriptName "`` to wait until you have?`nOr would you like to select the checklist file now?", msgTitle, "4 32 4096")
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
            getPath(openProg.winTitle, dashLocation, &checklist, &logs, &path)
        end:
    }

#Include <checklist\verCheck>

;// getting the title
;// I keep my project files withhin a subfolder of the overall project folder
;// so I use a function to provide the path of the directory one step back from the project folder
;// simply make this block here `SplitPath(path, &name)` if you keep your project file in the root project directory
SplitPath(WinGet.pathU(path "\.."), &name)

;// grabbing hour information from ini file
getTime := IniRead(checklist, "Info", "time")
timeForLog := Round(getTime / 3600, 3)
if getTime = 0
    timeForLog := "0.000"
;// checking for log file
if !FileExist(logs)
    FileAppend("Initial creation time : " today ", " A_Hour ":" A_Min ":" A_Sec "`n`n{ " today " - " timeForLog "`n", logs)

;// checking the date
newDate(&today)

;// constructing the GUI
#Include <checklist\contruct>

;// log opening
FileAppend("\\ The checklist was opened : " A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec " -- Hours after opening = " startHoursRounded " -- seconds at opening = " startValue "`n", logs)

;// setting dark/light mode
(darkToolTrack = 1) ? which() : which(false, "Light", 0)

checklistGUI.Show("AutoSize NoActivate", {DarkBG: false})
checklistGUI.BackColor := checklistGUI.LightColour
checklistGUI.Move(-345, -191,,) ;I have it set to move onto one of my other monitors, if you notice that you can't see it after opening or it keeps warping to a weird location, this line of code is why
;// finish defining GUI

#Include <checklist\close>