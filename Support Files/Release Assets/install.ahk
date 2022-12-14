;// This file is the file that gets turned into the release.exe that is sent out as a release

;// setting up
SetWorkingDir(A_ScriptDir) ;! A_ScriptDir in this case is the users install location
A_ScriptName := "yes.value"

;// making sure files haven't already been extracted
if FileExist(A_WorkingDir "\My Scripts.ahk") || FileExist(A_WorkingDir "\right click premiere.ahk") || FileExist(A_WorkingDir "\checklist.ahk") || FileExist(A_WorkingDir "\yes.value.zip")
    {
        MsgBox("There appears to already be extracted files in this directory, remove them before running this file or you may enounter issues")
        return
    }

;// alerting the user before starting
alert := MsgBox("This install process requires either 7zip to be installed, or PowerShell 5+ and .Net4.5 (or greater)`n`nIf you do not have either installed, this installer will step you through obtaining PowerShell 7 and .Net7", "Notice", "1 64 256 4096")
if alert = "Cancel"
    return
check := MsgBox("This install process will dump my entire repo in the current directory.`n`nDo you wish to continue?", "Do you wish to continue?", "4 32 256 4096")
if check = "No"
    return
;// dumping all required files
FileInstall("E:\Github\ahk\releases\release\yes.value.zip", A_WorkingDir "\yes.value.zip", 1)
FileInstall("E:\Github\ahk\releases\release\Extract.ahk", A_WorkingDir "\Extract.ahk", 1)
FileInstall("E:\Github\ahk\releases\release\SevenZip.ahk", A_WorkingDir "\SevenZip.ahk", 1)
FileInstall("E:\Github\ahk\releases\release\7-zip32.dll", A_WorkingDir "\7-zip32.dll", 1)
FileInstall("E:\Github\ahk\releases\release\7-zip64.dll", A_WorkingDir "\7-zip64.dll", 1)

;// setting location vars
releaseGUILoc := A_WorkingDir "\Support Files\Release Assets\releaseGUI.ahk"
readmeLoc     := A_WorkingDir "\Support Files\Release Assets\Getting Started_readme.md"

;// running extract script
RunWait(A_WorkingDir '\Extract.ahk')

;// cleaning up files that are no longer needed
FileDelete(A_WorkingDir '\7-zip32.dll')
FileDelete(A_WorkingDir '\7-zip64.dll')
FileDelete(A_WorkingDir '\SevenZip.ahk')
FileDelete(A_WorkingDir '\Extract.ahk')
FileDelete(A_WorkingDir '\yes.value.zip')
sleep 100

;// checking if releaseGUI.ahk doesn't exist/can't be found
if !FileExist(releaseGUILoc)
    {
        loop {
            if A_Index > 10
                {
                    ;// last ditch effort to find the gui file
                    loop files A_WorkingDir "\*.ahk", "F R"
                        {
                            if A_LoopFileName != "releaseGUI.ahk"
                                continue
                            releaseGUILoc := A_LoopFileFullPath
                            break
                        }
                    ;// if the file still can't be found, we'll back out
                    MsgBox("The installer file couldn't find " "'" "releaseGUI.ahk" "'" ", it should be in:`n" releaseGUILoc "`n`nIf that file is there and there is a problem with this installer, simply run that script and read the readme.md found here:`n" readmeLoc)
                    return
                }
            sleep 250
            if FileExist(releaseGUILoc)
                break
        }
    }
;// if it can be found, run it
coordmode("pixel", "screen"), coordmode("mouse", "screen")
Run(releaseGUILoc)
if !WinWait("Select Install Options",, 5)
    {
        MsgBox("Waiting for releaseGUI.ahk timed out`nYou can run this file manually to get started:`n" releaseGUILoc "`n`nThen checkout the readme.md file found in the same directory:`n" readmeLoc)
        return
    }
sleep(500)
WinGetPos(&x, &y, &width, &height, "Select Install Options")

;// checking to see if the readme.md file can be found
if FileExist(readmeLoc)
    {
        Run("Notepad.exe " readmeLoc,,, &readmeID)
        if WinWait("ahk_pid " readmeID,, 3)
            {
                WinGetPos(,,, &noteHeight, notepadName := WinGetTitle("ahk_pid " readmeID))
                WinMove(x+width+15, (y+(height/2))-((noteHeight/2)), A_ScreenWidth/2.5, A_ScreenHeight/2.5, notepadName)
            }
    }