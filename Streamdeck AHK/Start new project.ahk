#SingleInstance Force
#Include "SD_functions.ahk"

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
SplitPath SelectedFolder, &name
if WinExist("Checklist - " name)
    {
        tool.Cust("You already have this checklist open")
        goto end
    }
Run("..\checklist.ahk")

end:
;; This part then just opens the project folder
Run(SelectedFolder)