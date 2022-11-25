#SingleInstance Force
; { \\ #Includes
#Include <\Classes\ptf>
; }

;; This part makes you select the folder you wish to create the nested folders in
SelectedFolder := FileSelect("D2", ptf.MyDir "\", "Create your desired folder then select it.")
if SelectedFolder = ""
    return

;; This part creates the folders I usually create for a project
DirCreate(SelectedFolder "\videos")
DirCreate(SelectedFolder "\proxies")
DirCreate(SelectedFolder "\audio")
DirCreate(SelectedFolder "\renders\draft") ;creates a folder to render drafts into
DirCreate(SelectedFolder "\renders\final") ;creates a folder to render the final into

;; This part then just opens the project folder
Run(SelectedFolder)