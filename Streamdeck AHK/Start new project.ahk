#SingleInstance Force
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\pause>
#Include <Functions\SD Functions\genProjDirs>
; }

pause.pause("autosave")
pause.pause("adobe fullscreen check")

;// Selecting the folder you wish to create the project in
if !SelectedFolder := genProjDirs() {
    pause.pause("autosave")
    pause.pause("adobe fullscreen check")
    return
}

;// This part then just opens/activates the project folder
if !WinExist(SelectedFolder)
    Run(SelectedFolder)
else if !WinActive(SelectedFolder)
    WinActivate(SelectedFolder)

pause.pause("autosave")
pause.pause("adobe fullscreen check")