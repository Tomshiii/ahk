;#SingleInstance Force ;don't want to accidentally start a second instance while it's mid move

;; This part makes you select the folder you wish to move
SelectedFolder := DirSelect("*E:\", 3, "Pick the folder you wish to move.")
if SelectedFolder = ""
    return

;;this part takes that folder directory and splits it out to just grab the final folder in the path as we need it below
FullFileName := SelectedFolder
SplitPath FullFileName, &name

;;this part makes you select the destination folder
Move := DirSelect("*A:\_RC\Tomshi\2021", 3, "Pick the destination folder you wish everything to move to.")
if Move = ""
    return

;;this part deletes the proxies folder and the draft folder if they exist
if DirExist(SelectedFolder "\proxies")
    DirDelete(SelectedFolder "\proxies", 1)
if DirExist(SelectedFolder "\Proxies")
    DirDelete(SelectedFolder "\Proxies", 1)
if DirExist(SelectedFolder "\renders\draft")
    DirDelete(SelectedFolder "\renders\draft", 1)
if DirExist(SelectedFolder "\renders\Draft")
    DirDelete(SelectedFolder "\renders\Draft", 1)

;;this part deletes any temp files if you have premiere/after effects set to save them next to their media
FileDelete(SelectedFolder "\videos\*.pek")
FileDelete(SelectedFolder "\videos\*.pkf")
FileDelete(SelectedFolder "\*.cfa")
FileDelete(SelectedFolder "\*.pek")

;;this part will delete any cache files buried within premiere's appdata folder because its settings to do so automatically literally never work. this will only happen if you use this script within the first week of a month
if A_DD < 8
    FileDelete(A_AppData "\Adobe\Common\Media Cache Files\*ims")

;;this part then moves your selected folder to the selected destination folder
DirMove(SelectedFolder, Move "\" %&name%)

;;this part just opens the final directory
Run(Move "\" %&name%)