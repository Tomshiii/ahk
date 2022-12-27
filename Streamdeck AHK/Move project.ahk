;#SingleInstance Force ;don't want to accidentally start a second instance while it's mid move
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\obj>
; }

;; This part makes you select the folder you wish to move
SelectedFolder := FileSelect("D2", ptf.MyDir "\", "Pick the folder you wish to move.")
if SelectedFolder = ""
    return

;;this part takes that folder directory and splits it out to just grab the final folder in the path as we need it below
splitSelected := obj.SplitPath(SelectedFolder)

;;this part makes you select the destination folder
move:
Move := FileSelect("D2", "N:\_RC\Tomshi\2022", "Pick the destination folder you wish everything to move to.")
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
if DirExist(SelectedFolder "\Premiere Composer Files")
    DirDelete(SelectedFolder "\Premiere Composer Files", 1)

;;this part deletes any temp files if you have premiere/after effects set to save them next to their media
FileDelete(SelectedFolder "\videos\*.pek")
FileDelete(SelectedFolder "\videos\*.pkf")
FileDelete(SelectedFolder "\audio\*.pek")
FileDelete(SelectedFolder "\audio\*.pkf")
FileDelete(SelectedFolder "\*.cfa")
FileDelete(SelectedFolder "\*.pek")
;delete any mkv files I might still have lying around in the videos folder (premiere can't use mkv files anyway so there's a 0% changce I haven't remuxed them into mp4's)
FileDelete(SelectedFolder "\videos\*.mkv")

;the below loop will go through and delete any files that are larger than 2GB (default) as I don't need to store anything larger than that
maxFileSizeGB := 2
loop files SelectedFolder "\videos\*.*", "R"
    {
        if A_LoopFileSize/1073741824 > maxFileSizeGB
            FileDelete(A_LoopFileFullPath)
        else
            continue
    }

;;this part then moves your selected folder to the selected destination folder
DirMove(SelectedFolder, Move "\" splitSelected.name)

;;this part just opens the final directory
Run(Move "\" splitSelected.name)