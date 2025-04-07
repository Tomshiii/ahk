; { \\ #Includes
#Include <Classes\winget>
#Include <Other\7zip\SevenZip>
; }

;// this script is very much just for my own work related workflow and won't really help anyone else sorryyy

activeWin := WinGet.ExplorerPath()
defaultDir := activeWin != false ? activeWin : ""
SelectedFolder := FileSelect("D2", defaultDir, "Select your desired project Folder.")
if SelectedFolder = ""
    return

if DirExist(SelectedFolder "\_proj") {
    if MsgBox("The ``_proj`` folder already exists which generally means this process was already running and was for some reason aborted. Do you wish to delete this directory and continue?", "Proceed or Cancel?", "OKCancel IconX 0x1000") = "Cancel"
        return
    DirDelete(SelectedFolder "\_proj", 1)
}

DirCreate(SelectedFolder "\_proj\_project files")
DirCreate(SelectedFolder "\_proj\audio")
DirCreate(SelectedFolder "\_proj\videos")

;// == _project files
loop files SelectedFolder "\_project files\*.*", 'FD' {
    if A_LoopFileName = "Motion Graphics Template Media" || A_LoopFileName = "Premiere Composer Files" || A_LoopFileName = "AC Footage"
        try DirCopy(A_LoopFileFullPath, SelectedFolder "\_proj\_project files\" A_LoopFileName)
    if A_LoopFileExt = "prproj" || A_LoopFileExt = "aep"
        try FileCopy(A_LoopFileFullPath, SelectedFolder "\_proj\_project files\*.*")
}

;// == audio
loop files SelectedFolder "\audio\*.*", 'F' {
    try FileCopy(A_LoopFileFullPath, SelectedFolder "\_proj\audio\*.*")
}

;// == video
loop files SelectedFolder "\videos\*.*", 'F' {
    if A_LoopFileExt = "mkv"
        continue
    if A_LoopFileSizeMB >= 3000 {
        if MsgBox("``" A_LoopFileName "`` is larger than 3GB, do you wish to include it?", "Include or Ignore?", "YesNo Icon?") = "No"
            continue
    }
    try FileCopy(A_LoopFileFullPath, SelectedFolder "\_proj\videos\*.*")
}
loop files SelectedFolder "\videos\*.*", 'D' {
    if A_LoopFileName = "footage"
        continue
    if MsgBox("Do you wish to backup the folder: ``" A_LoopFileName "`` contained in the 'videos' directory?", "Include or Ignore?", "YesNo Icon?") = "No"
        continue
    try DirCopy(A_LoopFileFullPath, SelectedFolder "\_proj\videos\*.*")
}

zip := SevenZip().AutoZip(SelectedFolder "\_proj")

DirDelete(SelectedFolder "\_proj", 1)