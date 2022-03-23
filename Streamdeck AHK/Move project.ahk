;#SingleInstance Force ;don't want to accidentally start a second instance while it's mid move

;; This part makes you select the folder you wish to move
SelectedFolder := FileSelect("D2", "E:\", "Pick the folder you wish to move.")
if SelectedFolder = ""
    return

;;this part takes that folder directory and splits it out to just grab the final folder in the path as we need it below
FullFileName := SelectedFolder
SplitPath FullFileName, &name

;;this part makes you select the destination folder
move:
Move := FileSelect("D2", "A:\_RC\Tomshi\2022", "Pick the destination folder you wish everything to move to.")
if Move = ""
    return
if Move = SelectedFolder
    {
        MsgBox("You can't move a folder to the same dir`nYou're going to crash ahk, is that what you want?")
        goto move
    }

;;this part deletes the proxies folder and the draft folder if they exist
if DirExist(SelectedFolder "\proxies")
    DirDelete(SelectedFolder "\proxies", 1)
if DirExist(SelectedFolder "\Proxies")
    DirDelete(SelectedFolder "\Proxies", 1)
if DirExist(SelectedFolder "\renders\draft")
    DirDelete(SelectedFolder "\renders\draft", 1)
if DirExist(SelectedFolder "\renders\Draft")
    DirDelete(SelectedFolder "\renders\Draft", 1)
if DirExist(SelectedFolder "\Adobe Premiere Pro Auto-Save")
    DirDelete(SelectedFolder "\Adobe Premiere Pro Auto-Save", 1)
if DirExist(SelectedFolder "\Adobe After Effects Auto-Save")
    DirDelete(SelectedFolder "\Adobe After Effects Auto-Save", 1)
if DirExist(SelectedFolder "\Adobe Premiere Pro Audio Previews")
    DirDelete(SelectedFolder "\Adobe Premiere Pro Audio Previews", 1)

;;this part deletes any temp files if you have premiere/after effects set to save them next to their media
FileDelete(SelectedFolder "\videos\*.pek")
FileDelete(SelectedFolder "\videos\*.pkf")
FileDelete(SelectedFolder "\audio\*.pek")
FileDelete(SelectedFolder "\audio\*.pkf")
FileDelete(SelectedFolder "\*.cfa")
FileDelete(SelectedFolder "\*.pek")

;;this part will delete any cache files buried within premiere's appdata folder because its settings to do so automatically literally never work. this will only happen if the folder is larger than you set below (in GB)

;SET HOW BIG YOU WANT IT TO WAIT FOR HERE (IN GB)
largestSize := 15
;then below checks the size and deletes if too large
FolderSize := 0
WhichFolder := A_AppData "\Adobe\Common\Media Cache Files\" 
Loop Files, WhichFolder "\*.*", "R"
    FolderSize += A_LoopFileSize
convert := FolderSize/"1073741824"
if convert >= largestSize
    FileDelete(A_AppData "\Adobe\Common\Media Cache Files\*.ims")

;;this part then moves your selected folder to the selected destination folder
DirMove(SelectedFolder, Move "\" %&name%)

;;this part just opens the final directory
Run(Move "\" %&name%)