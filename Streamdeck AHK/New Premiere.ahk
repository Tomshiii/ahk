#SingleInstance Force
SetWorkingDir A_ScriptDir
SetDefaultMouseSpeed 0
#Include SD_functions.ahk

;This version of the script (from 5th May, 2022) is designed for Premiere v22.3.1 (and beyond)
;Previous versions compatible with Premiere v22.3 can be found in previous releases of this repo (v2.3.3 and below)

If WinActive("ahk_exe Adobe Premiere Pro.exe")
    {
        ;; This part makes you select the folder you wish to create the project in
        SelectedFolder := FileSelect("D2", "E:\", "Select your desired Folder. This Script will create the necessary sub folders")
        if SelectedFolder = ""
            return
        pauseautosave()
        pausewindowmax()
        DirCreate(SelectedFolder "\videos") ;creates a video folder if there isn't one already
        DirCreate(SelectedFolder "\audio") ;creates an audio folder if there isn't one already
        DirCreate(SelectedFolder "\proxies") ;creates the proxy folder we'll need later
        DirCreate(SelectedFolder "\renders\draft") ;creates a folder to render drafts into
        DirCreate(SelectedFolder "\renders\final") ;creates a folder to render the final into

        SplitPath(SelectedFolder, &default) ;this gets the name of the project folder to use as a default for the below inputbox
        IB := InputBox("Enter the name of your project", "Project", "w100 h100", %&default%)
            if IB.Result = "Cancel"
                {
                    pauseautosave()
                    pausewindowmax()
                    return
                }
        WinActivate("ahk_exe Adobe Premiere Pro.exe")
        coordw()
        blockOn()
        sleep 200
        if ImageSearch(&x, &y, 0, 0, 629, 348, "*2 " Premiere "newProj.png")
            {
                MouseMove(%&x%, %&y%)
                SendInput("{Click}")
                sleep 1000
                loop {
                    sleep 1000
                    if ImageSearch(&nox, &noy, 1219, 54, 1347, 85, "*2 " Premiere "noProj.png")
                        break
                    if A_Index > 5
                        {
                            toolCust("Couldn't ensure the new project window opened", "2000")
                            pauseautosave()
                            pausewindowmax()
                            blockOff()
                            return
                        }
                }
                sleep 1000
                WinActivate("ahk_exe Adobe Premiere Pro.exe")
                SendInput(IB.Value) ;INSERT PROJECT NAME HERE
                sleep 100
                SendInput("{Tab}")
                sleep 200
                SendInput("{Space}")
                sleep 500
                SendInput("{Up}")
                sleep 1000
                SendInput("{Space}")
                sleep 50
                WinWait("Project Location")
                sleep 500
                SendInput("{F4}")
                sleep 300
                SendInput("^a" "+{BackSpace}" SelectedFolder) ;SEND PATH HERE
                sleep 100
                SendInput("{Enter}")
                sleep 1000
                MouseMove(348, 15)
                SendInput("{Click}")
                sleep 100
                SendInput("{Enter 4}")
                sleep 1000
                loop {
                    if ImageSearch(&crex, &crey, 2290, 1274, 2559, 1349, "*2 " Premiere "create.png")
                    {
                        MouseMove(%&crex%, %&crey%)
                        SendInput("{Click}")
                        WinWaitClose("Save Project")
                        sleep 1500
                        break
                    }
                    sleep 250
                    if A_Index > 5
                        {
                            toolCust("couldn't find the create button", "2000")
                            pauseautosave()
                            pausewindowmax()
                            blockOff()
                            return
                        }
                    }
                sleep 1000
                SendInput("^n")
                if WinWait("New Sequence",, 2)
                    goto proceed
                else
                    {
                        sleep 1000
                        WinActivate("ahk_exe Adobe Premiere Pro.exe")
                        SendInput("^n")
                    }
                proceed:
                SendInput("{Enter}")
                SendInput(premIngest) ;we want to use a shortcut here instead of trying to navigate the alt menu because the alt menu is unreliable and often doesn't work as intended in scripts
                if WinWait("Project Settings",, 2)
                    goto proceed2
                else
                    {
                        sleep 1000
                        WinActivate("ahk_exe Adobe Premiere Pro.exe")
                        SendInput(premIngest) ;we want to use a shortcut here instead of trying to navigate the alt menu because the alt menu is unreliable and often doesn't work as intended in scripts
                    }
                proceed2: ;this section is to set the proxy
                sleep 1000
                WinActivate("Project Settings")
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
                SendInput("^a" "+{BackSpace}" SelectedFolder "\proxies") ;INSERT PATH AND PROXIES HERE
                sleep 800
                SendInput("{Enter}")
                sleep 250
                SendInput("+{Tab 5}")
                sleep 250
                SendInput("{Enter}")
                sleep 2000
                SendInput("{Tab}" "{Space}") ;if you're on premiere v22.5 or above you'll need 2 tabs here. I've downgraded back to 22.3.1 for stability reasons
                sleep 1000
                blockOff()
                Run(SelectedFolder) ;open an explorer window for your selected directory
                SplitPath SelectedFolder, &name
	            if WinExist("Checklist - " %&name%)
                    {
                        toolCust("You already have this checklist open", "1000")
                        goto end
                    }
                try {
                    FileCopy(location "\checklist.ahk", SelectedFolder)
                    Run(SelectedFolder "\checklist.ahk")
                } catch as e {
                    toolCust("File not found", "1000")
                }
                end:
                pauseautosave()
                pausewindowmax()
                return
            }
        else
            {
                pauseautosave()
                pausewindowmax()
                blockOff()
                toolFind("the new project button", "1000")
                return
            }
    }