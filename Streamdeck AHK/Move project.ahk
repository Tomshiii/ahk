#SingleInstance Off ;// multiple processes can happen at once

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\obj>
; }

;// select the directory you wish to move
if !SelectedFolder := FileSelect("D2", ptf.MyDir "\", "Pick the folder you wish to move.")
    return

;// taking that folder directory and spliting it out to just grab the final folder in the path as we need it below
splitSelected := obj.SplitPath(SelectedFolder)

;// selecting the destination folder directory
Move := FileSelect("D2", "N:\_RC\Tomshi\" A_Year, "Pick the destination folder you wish everything to move to.")
if Move = ""
    return
if Move = SelectedFolder
    {
        MsgBox("You can't move a folder to the same dir`nYou're going to crash ahk, is that what you want?")
        return
    }

;// deleting any temp directories that contain files we don't need to store
folders := ["\proxies", "\renders\draft", "\Adobe Premiere Pro Audio Previews", "\Adobe Premiere Pro Video Previews", "\Adobe Premiere Pro Auto-Save", "\Adobe After Effects Auto-Save"]
for v in folders {
    if DirExist(SelectedFolder v)
        DirDelete(SelectedFolder v, 1)
}

;// delete all backups except the most recently modified
if DirExist(SelectedFolder "\_project files\Backup") {
    newestmodifiedtime := ""
    newestmodifiedname := ""
    loop files SelectedFolder "\_project files\Backup\*", "D" {
        if newestmodifiedtime = "" || A_LoopFileTimeModified > newestmodifiedtime {
            newestmodifiedtime := A_LoopFileTimeModified
            newestmodifiedname := A_LoopFileName
        }
    }
    loop files SelectedFolder "\_project files\Backup\*", "D" {
        if A_LoopFileName != newestmodifiedname
            DirDelete(SelectedFolder "\_project files\Backup\" A_LoopFileName "\", 1)
    }
}

;// deleting any temp files if you have premiere/after effects set to save them next to their media
;// also deletes any mkv files that might still be lying around in the videos folder (premiere can't use mkv files - so there's a 0% chance I haven't remuxed them into mp4's)
files := ["\videos\*.pek", "\videos\*.pkf", "\audio\*.pek", "\audio\*.pkf", "\*.cfa", "\*.pek", "\videos\*.mkv"]
for v in files {
    FileDelete(SelectedFolder v)
}

;// the below loop will go through and delete any files in the videos dir that are larger than 2GB (default) as I don't really need to store anything larger than that
maxFileSizeGB := 2
loop files SelectedFolder "\videos\*.*", "R"
    {
        if A_LoopFileSize/1073741824 > maxFileSizeGB
            FileDelete(A_LoopFileFullPath)
        else
            continue
    }

;// moving your selected directory to the selected destination folder
DirMove(SelectedFolder, Move "\" splitSelected.name)

;// open the final directory and produce a tooltip to alert the user that the process is complete
Run(Move "\" splitSelected.name)
tool.tray({text: "Moving: " SelectedFolder "`nComplete"})