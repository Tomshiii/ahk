#SingleInstance Force
SetWorkingDir(A_ScriptDir)
SetDefaultMouseSpeed(0)

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\ptf>
#Include <Classes\switchTo>
#Include <Classes\pause>
#Include <Classes\coord>
#Include <Classes\block>
#Include <Classes\Editors\Premiere>
#Include <Functions\SD Functions\genProjDirs>
#Include <Functions\delaySI>
; }

;// This version of the script (from 19th Dec, 2022) is designed for Premiere v22.3.1 (and beyond) - it copies a template project folder out of the `..\Backups\Adobe Backups\Premiere\Template\` folder and places it in the desired project folder. It then handles changing the proxy location
;// it runs the version of premiere set within `settingsGUI()`

pause.pause("autosave")
pause.pause("adobe fullscreen check")

if !SelectedFolder := genProjDirs() {
    pause.pause("autosave")
    pause.pause("adobe fullscreen check")
    return
}

;// Getting the name of the project folder to use as a default for the below inputbox
SplitPath(SelectedFolder, &default)
IB := InputBox("Enter the name of your project", "Project", "w100 h100", default)
if IB.Result = "Cancel" {
    pause.pause("autosave")
    pause.pause("adobe fullscreen check")
    return
}
;// Copying over the template file
count := 0
loop files ptf["premTemp"] "\*.prproj", "F" {
    chosenFile := A_LoopFileFullPath
    count++
}
if count > 1 {
    chosenFile := FileSelect("2", ptf["premTemp"], "Select the desired Project Template.", "Premiere Project File (*.prproj)")
    if chosenFile = "" {
        pause.pause("autosave")
        pause.pause("adobe fullscreen check")
        return
    }
}
FileCopy(chosenFile, SelectedFolder "\_project files\" IB.Value ".prproj")
if !FileExist(prem.path) {
    try RunWait(ptf.SupportFiles "\shortcuts\createShortcuts.ahk", ptf.SupportFiles "\shortcuts\")
    sleep 100
    if !FileExist(prem.path) {
        ;// throw
        errorLog(TargetError("Shortcut file has not been generated.`nPlease run ``createShortcuts.ahk``"),,, true)
        return
    }
}
Run(prem.path A_Space '"' SelectedFolder "\_project files\" IB.Value ".prproj" '"')
if !WinWait("Open Project",, 20) {
    check := MsgBox("Script didn't encounter Open Project window, can the script proceed?", "Check", "4 32 4096")
    if check = "No" {
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
switchTo.Premiere()

pause.pause("autosave")
pause.pause("adobe fullscreen check")
block.Off()