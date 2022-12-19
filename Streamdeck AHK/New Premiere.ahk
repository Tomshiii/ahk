#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\pause>
#Include <Classes\coord>
#Include <Classes\block>
; }

;//This version of the script (from 19th Dec, 2022) is designed for Premiere v22.3.1 (and beyond) - it copies a template project folder out of the `..\Backups\Adobe Backups\Premiere\Template\` folder and places it in the desired project folder. It then handles changing the proxy location

;// Selecting the folder you wish to create the project in
SelectedFolder := FileSelect("D2", ptf.MyDir "\", "Select your desired Folder. This Script will create the necessary sub folders")
if SelectedFolder = ""
    return
pause.pause("autosave")
pause.pause("adobe fullscreen check")
DirCreate(SelectedFolder "\videos") ;creates a video folder if there isn't one already
DirCreate(SelectedFolder "\audio") ;creates an audio folder if there isn't one already
DirCreate(SelectedFolder "\proxies") ;creates the proxy folder we'll need later
DirCreate(SelectedFolder "\renders\draft") ;creates a folder to render drafts into
DirCreate(SelectedFolder "\renders\final") ;creates a folder to render the final into

;// Getting the name of the project folder to use as a default for the below inputbox
SplitPath(SelectedFolder, &default)
IB := InputBox("Enter the name of your project", "Project", "w100 h100", default)
    if IB.Result = "Cancel"
        {
            pause.pause("autosave")
            pause.pause("adobe fullscreen check")
            return
        }
;// Copying over the template file
FileCopy(ptf["premTemp"], SelectedFolder "\" IB.Value ".prproj")
Run(SelectedFolder "\" IB.Value ".prproj")
if !WinWait("Open Project",, 20)
    {
        check := MsgBox("Script didn't encounter Open Project window, can the script proceed?", "Check", "4 32 4096")
        if check = "No"
            {
                pause.pause("autosave")
                pause.pause("adobe fullscreen check")
                return
            }
        goto skip
    }
;! // make the below use something other than sleep??
;// waiting for premiere to load
sleep 5000
skip:
block.On()
SendInput(premIngest) ;we want to use a shortcut here instead of trying to navigate the alt menu because the alt menu is unreliable and often doesn't work as intended in scripts
if !WinWait("Project Settings",, 2)
    {
        sleep 1000
        WinActivate(editors.Premiere.winTitle)
        SendInput(premIngest) ;we want to use a shortcut here instead of trying to navigate the alt menu because the alt menu is unreliable and often doesn't work as intended in scripts
        if !WinWait("Project Settings",, 2)
            {
                block.Off()
                MsgBox("Opening Injest settings failed")
                pause.pause("autosave")
                pause.pause("adobe fullscreen check")
                return
            }
    }
sleep 1000
WinActivate("Project Settings")
coord.s()
MouseGetPos(&x, &y)
coord.c()
coord.s()
MouseMove(0, 0, 2) ;// get it out of the way
sleep 50
SendInput("{Tab 3}")
sleep 500
SendInput("{Space}")
sleep 1000
SendInput("{Tab}" "{Space}" "{Down 2}" "{Space}")
sleep 1000
SendInput("{Tab}" "{Space}")
sleep 300
SendInput("{Down 3}" "{Space}")
sleep 300
SendInput("{Tab 2}" "{Space}")
sleep 300
SendInput("{Up}" "{Space}")
WinWait("Select Folder")
sleep 800
SendInput("{F4}")
sleep 800
SendInput("^a" "+{BackSpace}")
SendText(SelectedFolder "\proxies") ;INSERT PATH AND PROXIES HERE
sleep 800
SendInput("{Enter}")
sleep 250
SendInput("+{Tab 5}")
sleep 250
SendInput("{Enter}")
sleep 2000
SendInput("{Tab}" "{Space}") ;if you're on premiere v22.5 or above you'll need 2 tabs here. I've downgraded back to 22.3.1 for stability reasons
sleep 1000
MouseMove(x, y, 2) ;// get it out of the way
block.Off()
Run(SelectedFolder) ;open an explorer window for your selected directory
SplitPath SelectedFolder, &name
if !WinExist("Checklist - " name)
    {
        try {
            Run(ptf["checklist"])
        } catch as e {
            tool.Cust("File not found")
        }
    }
pause.pause("autosave")
pause.pause("adobe fullscreen check")