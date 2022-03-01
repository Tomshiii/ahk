#SingleInstance Force

;; This part makes you select the folder you wish to create the nested folders in
SelectedFolder := FileSelect("D2", "E:\", "Create your desired folder then select it.")
if SelectedFolder = ""
    return

;; This part creates the folders I usually create for a project
DirCreate(SelectedFolder "\videos")
DirCreate(SelectedFolder "\proxies")
DirCreate(SelectedFolder "\audio")
DirCreate(SelectedFolder "\renders\draft") ;creates a folder to render drafts into
DirCreate(SelectedFolder "\renders\final") ;creates a folder to render the final into
FileCopy(A_ScriptDir "\checklist.ahk", SelectedFolder)
Run(SelectedFolder "\checklist.ahk")

;; This part then just opens the project folder
Run(SelectedFolder)