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
;// if you show full path in titlebar
/*
if !WinExist(SelectedFolder)
    Run(SelectedFolder)
else if !WinActive(SelectedFolder)
    WinActivate(SelectedFolder)
*/

;// if you only show current dir in titlebar
SplitPath(SelectedFolder, &title)
if !WinExist(title)
    Run(SelectedFolder)
else if !WinActive(title)
    WinActivate(title)

pause.pause("autosave")
pause.pause("adobe fullscreen check")