#SingleInstance Force

;; This part makes you select the folder you wish to create the nested folders in
SelectedFolder := DirSelect("*E:\", 3, "Create your desired folder then select it.")
if SelectedFolder = ""
    return

;; This part creates the folders I usually create for a project
DirCreate(SelectedFolder "\videos")
DirCreate(SelectedFolder "\proxies")
DirCreate(SelectedFolder "\audio")

;; This part then just opens the project folder
Run(SelectedFolder)