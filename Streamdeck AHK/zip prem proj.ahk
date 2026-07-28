; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\explorer.ahk
#Include Classes\notifyExt.ahk
#Include GUIs\tomshiBasic.ahk
#Include Other\7zip\SevenZip.ahk
; }

;// this script is very much just for my own work related workflow and won't really help anyone else sorryyy

activeWin := explorer.getPath()
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

includeDirs := []
dirsMap := Map()
includeFiles := []
filesMap := Map()

class checkGui extends GUI {
    __New(incArr, incMap, startingDir, dirOrFile) {
        if incArr.Length >= 1 {
        ignoreExit := false
        extraTitle := "Backup Extra " dirOrFile
        extraGUI := tomshiBasic(,, "+resize +MinSize200x150", extraTitle)
        extraGUI.AddText("Section", "Select the video " StrLower(dirOrFile) " you wish to`nadditionally backup.")
        bottomY := ""
        for v in incArr {
            xpos := (Mod(A_Index, 9) != 0) ? "xs" : "xs+150" " ys Section"
            onFirst := (A_Index = 1) ? "Section" : ""
            extraGUI.AddCheckbox(xpos " v" StrReplace(v, A_Space, "___") " " onFirst, " \" v)
            if xpos != "xs"
                bottomY := "v" StrReplace(v, A_Space, "___")
        }

        extraGUI.AddButton("xs y+25", "Backup").OnEvent("Click", __doBackupButt.Bind("backup"))
        extraGUI.AddButton("x+5", "Ignore").OnEvent("Click", __doBackupButt.Bind("ignore"))
        extraGUI.AddButton("xs y+5", "Backup All").OnEvent("Click", __doBackupButt.Bind("backupall"))
        extraGUI.AddButton("x+5 Default", "Ignore All").OnEvent("Click", (*) => extraGUI.Destroy())
        extraGUI.Show()
        extraGUI.OnEvent('Close', __determineExit)
        extraGUI.Opt("-Resize")
        WinWaitClose(extraTitle)
        ignoreExit := true
        __doBackupButt(which, *) {
            NamedCtrlValues := extraGUI.Submit()
            for k, v in NamedCtrlValues.OwnProps() {
                switch which {
                    case "backup":
                        if !v
                            continue
                        incMap.Set(startingDir "\" StrReplace(k, "___", A_Space), true)
                    case "ignore":
                        if v
                            continue
                        incMap.Set(startingDir "\" StrReplace(k, "___", A_Space), true)
                    case "backupall": incMap.Set(startingDir "\" StrReplace(k, "___", A_Space), true)
                }
            }
        }
        __determineExit(*) {
            if ignoreExit
                return
            ExitApp()
        }
    }
    }
}

loop files SelectedFolder "\videos\*", "D" {
    if A_LoopFileName != "footage" && A_LoopFileName != "_footage" && A_LoopFileName != "proxies" && A_LoopFileName != "_proxies"
        includeDirs.Push(A_LoopFileName)
}
loop files SelectedFolder "\videos\*.*", 'F' {
    if A_LoopFileExt = "mkv"
        continue
    if A_LoopFileSizeMB >= 3000
        includeFiles.Push(A_LoopFileName)
}

dirs := checkGui(includeDirs, dirsMap, SelectedFolder "\videos", "Directories")
fs   := checkGui(includeFiles, filesMap, SelectedFolder "\videos", "Files")

;// == _project files
loop files SelectedFolder "\_project files\*.*", 'FD' {
    allowed := Map("Motion Graphics Template Media", true, "Premiere Composer Files", true, "AC Footage", true, "Main Channel AE Templates", true, "Adobe Premiere Pro Captured and Generated", true, "Adobe Premiere Pro Audio Previews", true, "templates", true, "fills", true)
    if allowed.Has(A_LoopFileName)
        try DirCopy(A_LoopFileFullPath, SelectedFolder "\_proj\_project files\" A_LoopFileName)
    if A_LoopFileExt = "prproj" || A_LoopFileExt = "aep"
        try FileCopy(A_LoopFileFullPath, SelectedFolder "\_proj\_project files\*.*")
}

;// == audio
loop files SelectedFolder "\audio\*.*", 'F' {
    try FileCopy(A_LoopFileFullPath, SelectedFolder "\_proj\audio\*.*")
}

;// == video
if dirsMap.Count > 0
    notifyExt.showIfNotExist("zipPremCopyingDir",, 'Your selected directories are being backed up!', 'C:\Windows\System32\imageres.dll|icon249', 'Windows Battery Critical',, 'dur=5 bc=Black show=Fade@250 hide=Fade@250 bdr=Yellow maxW=400')
for k in dirsMap {
    SplitPath(k, &dirName)
    try DirCopy(k, SelectedFolder "\_proj\videos\" dirName)
}
notifyExt.deleteIfExist("zipPremCopyingDir")
notifyExt.showIfNotExist("zipPremCopyingFiles",, 'Copying files in your videos folder + any selected large files', 'C:\Windows\System32\imageres.dll|icon249', 'Windows Battery Critical',, 'dur=5 bc=Black show=Fade@250 hide=Fade@250 bdr=Yellow maxW=400')
loop files SelectedFolder "\videos\*.*", 'F' {
    if A_LoopFileExt = "mkv"
        continue
    if A_LoopFileSizeMB >= 3000 {
        if !filesMap.Has(A_LoopFileFullPath)
            continue
    }
    try FileCopy(A_LoopFileFullPath, SelectedFolder "\_proj\videos\*.*")
}
notifyExt.deleteIfExist("zipPremCopyingFiles")
zip := SevenZip().AutoZip(SelectedFolder "\_proj")

DirDelete(SelectedFolder "\_proj", 1)