#SingleInstance Force
SetWorkingDir(A_ScriptDir)
SetDefaultMouseSpeed(0)

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\ptf.ahk
#Include Classes\switchTo.ahk
#Include Classes\pause.ahk
#Include Classes\coord.ahk
#Include Classes\block.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\Editors\Premiere.ahk
#Include Functions\SD Functions\genProjDirs.ahk
#Include Functions\delaySI.ahk
#Include Functions\notifyIfNotExist.ahk
; }

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

templatesDir := SelectedFolder "\_project files\templates"
mainTemplate := "W:\_Assets\Plugins & Presets\Mogrts & Presets\Main Channel AE Templates\Regular videos\The Boys Main Channel - Regular Template.aet"
hauntTemplate := "W:\_Assets\Plugins & Presets\Mogrts & Presets\Main Channel AE Templates\Haunted videos\The Boys Main Channel - Haunted Template.aet"
try {
    UserSettings := CLSID_Objs.load("UserSettings")
    aeIco := A_ProgramFiles "\Adobe\Adobe After Effects " UserSettings.ae_year "\Support Files\UXP\plugins\com.adobe.ccx.start\images\thumbs\AEFT_aep.ico"
}
if !IsSet(aeIco)
    aeIco := 'C:\Windows\System32\shell32.dll|icon153'
if !DirExist(templatesDir)
    DirCreate(templatesDir)
(FileExist(mainTemplate)) ? FileCopy(mainTemplate, templatesDir, true) : notifyIfNotExist("aeNoMainTemplate", 'AE Main Template file doesn`'t exist', aeIco,,, 'bdr=Red maxW=400')
(FileExist(hauntTemplate)) ? FileCopy(hauntTemplate, templatesDir, true) : notifyIfNotExist("aeNoHauntedTemplate", 'AE Haunted Template file doesn`'t exist', aeIco,,, 'bdr=Red maxW=400')

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