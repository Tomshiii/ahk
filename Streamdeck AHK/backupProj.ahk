; { \\ #Includes
#Include <Classes\winget>
#Include <Classes\Streamdeck_opt>
#Include <Classes\obj>
#Include <Classes\Editors\Premiere>
#Include <Other\Notify\Notify>
;
if WinExist(prem.winTitle) {
    try {
        path := WinGet.ProjPath()
        defaultDir := path.dir
    } catch {
        ;// same as below
        defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""
    }
}
else
    defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""
if !projectFolder := FileSelect("D 3", defaultDir, "Select Folder Containing Project Files")
    return
sd := SD_Opt()
if !DirExist(sd.backupFolder) {
    Notify.Show(, 'You can set your backup location in;`n..\Support Files\Streamdeck Files\options.ini', 'C:\Windows\System32\imageres.dll|icon77', 'Windows Balloon',, 'dur=6 show=Fade@250 hide=Fade@250 bdr=0xC72424')
    if !backupFolder := FileSelect("D 3", defaultDir, "Select Location you wish to Backup to")
        return
}
else
    backupFolder := sd.backupFolder

additionalDir := []
nonFootage := []
videosFolder := WinGet.pathU(projectFolder "\..\videos")
loop files videosFolder "\*", "D" {
    if A_LoopFileName != "footage"
        nonFootage.Push(A_LoopFileName)
}
if nonFootage.Length >= 1 {
    loop {
        userResponse := MsgBox("Would you like to backup an additional video folder?`n`n*note: Already backed up files will NOT be overriden.`nThis function also assumes the selected directory is in the VIDEOS folder.", "Additional Video Folders?", "292")
        if (userResponse != "Yes")
            break
        additionalDir.Push(FileSelect("D3", videosFolder))
    }
}

;// folders to backup
backFolders := ["AC Footage", "Adobe After Effects Auto-Save", "Adobe After Effects Auto-Save  (Beta)", "Adobe Premiere Pro Auto-Save", "Adobe Premiere Pro Auto-Save (Beta)", "Motion Graphics Template Media", "Premiere Composer Files"]

rootDir := SubStr(folder := WinGet.pathU(projectFolder "\..\"), -1, 1) = "\" ? SubStr(folder, 1, StrLen(folder)-1) : folder
proj := obj.SplitPath(rootDir)

__doBackup(backupFolder, additionalDir) {
    ;// creating necessary destination folders
    if !DirExist(backupFolder "\" proj.Name)
        DirCreate(backupFolder "\" proj.Name)
    backupFolder := backupFolder "\" proj.Name
    if !DirExist(backupFolder "\_Additional Assets\videos")
        DirCreate(backupFolder "\_Additional Assets\videos")
    if !DirExist(backupFolder "\_Additional Assets\audio\music")
        DirCreate(backupFolder "\_Additional Assets\audio\music")
    if !DirExist(backupFolder "\_Additional Assets\audio\sfx")
        DirCreate(backupFolder "\_Additional Assets\audio\sfx")
    if !DirExist(backupFolder "\" A_YYYY "-" A_MM "-" A_DD)
        DirCreate(backupFolder "\" A_YYYY "-" A_MM "-" A_DD)


    ;// copying project
    loop files projectFolder "\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\" A_YYYY "-" A_MM "-" A_DD "\*.*", true)
    }

    for _, v in backFolders {
        try DirCopy(projectFolder "\" v, backupFolder "\" A_YYYY "-" A_MM "-" A_DD "\" v, false)
    }

    loop files rootDir "\videos\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\_Additional Assets\videos\*.*", false)
    }

    loop files rootDir "\videos\footage\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\_Additional Assets\videos\*.*", false)
    }

    loop files rootDir "\audio\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\_Additional Assets\audio\*.*", false)
    }

    loop files rootDir "\audio\music\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\_Additional Assets\audio\music\*.*", false)
    }

    loop files rootDir "\audio\sfx\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\_Additional Assets\audio\sfx\*.*", false)
    }

    for v in additionalDir {
        SplitPath(v, &dirName)
        try DirCopy(v, backupFolder "\_Additional Assets\videos\" dirName)
    }
}

Notify.Show(, 'Your project is being backed up!', 'C:\Windows\System32\imageres.dll|icon249', 'Windows Battery Critical',, 'dur=5 bc=Black show=Fade@250 hide=None bdr=Yellow')
__doBackup(backupFolder, additionalDir)
if !DirExist(sd.backupFolderWork)
    return
backupFolder := sd.backupFolderWork
__doBackup(backupFolder, additionalDir)
