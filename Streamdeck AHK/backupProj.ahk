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
    ignoreExit := false
    extraTitle := "Backup Extra Directories"
    extraGUI := tomshiBasic(,, "+resize +MinSize200x150", extraTitle)
    extraGUI.AddText("Section", "Select the video directories you wish to`nadditionally backup.")
    bottomY := ""
    for v in nonFootage {
        xpos := (Mod(A_Index, 9) != 0) ? "xs" : "xs+150" " ys Section"
        onFirst := (A_Index = 1) ? "Section" : ""
        extraGUI.AddCheckbox(xpos " v" StrReplace(v, A_Space, "_") " " onFirst, " \" v)
        if xpos != "xs"
            bottomY := "v" StrReplace(v, A_Space, "_")
    }

    extraGUI.AddButton("xs y+25", "Backup").OnEvent("Click", __doBackupButt.Bind("backup"))
    extraGUI.AddButton("x+5", "Ignore").OnEvent("Click", __doBackupButt.Bind("ignore"))
    extraGUI.AddButton("xs y+5", "Backup All").OnEvent("Click", __doBackupButt.Bind("backupall"))
    extraGUI.AddButton("x+5", "Ignore All").OnEvent("Click", (*) => extraGUI.Destroy())
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
                    additionalDir.Push(videosFolder "\" k)
                case "ignore":
                    if v
                        continue
                    additionalDir.Push(videosFolder "\" k)
                case "backupall": additionalDir.Push(videosFolder "\" k)
            }
        }
    }
    __determineExit(*) {
        if ignoreExit
            return
        ExitApp()
    }
}

;// folders to backup
autoSaves := ["Adobe After Effects Auto-Save", "Adobe After Effects Auto-Save (Beta)", "Adobe Premiere Pro Auto-Save", "Adobe Premiere Pro Auto-Save (Beta)"]
backFolders := ["Adobe Premiere Pro Audio Previews", "Adobe Premiere Pro Captured and Generated", "AC Footage", "Motion Graphics Template Media", "Premiere Composer Files"]

rootDir := SubStr(folder := WinGet.pathU(projectFolder "\..\"), -1, 1) = "\" ? SubStr(folder, 1, StrLen(folder)-1) : folder
proj := obj.SplitPath(rootDir)

__doBackup(backupFolder, additionalDir) {
    ;// creating necessary destination folders
    __existCreate(dir) {
        if !DirExist(dir)
            DirCreate(dir)
    }
    __existCreate(backupFolder "\" proj.Name)
    backupFolder := backupFolder "\" proj.Name
    __existCreate(backupFolder "\_Additional Assets\auto save")
    __existCreate(backupFolder "\_Additional Assets\proj dirs")

    __existCreate(backupFolder "\_Additional Assets\videos")
    __existCreate(backupFolder "\_Additional Assets\audio\music")
    __existCreate(backupFolder "\_Additional Assets\audio\sfx")
    __existCreate(backupFolder "\" A_YYYY "-" A_MM "-" A_DD)


    ;// copying project
    loop files projectFolder "\*", 'F' {
        try FileCopy(A_LoopFileFullPath, backupFolder "\" A_YYYY "-" A_MM "-" A_DD "\*.*", true)
    }

    for v in autoSaves {
         if DirExist(projectFolder "\" v)
            try cmd.run(,,, Format('Robocopy "{1}" "{2}" *.* /MIR /R:1', projectFolder "\" v, backupFolder "\_Additional Assets\auto save\" v),, "hide")
    }
    for v in backFolders {
        if DirExist(projectFolder "\" v)
            try cmd.run(,,, Format('Robocopy "{1}" "{2}" *.* /MIR /R:1', projectFolder "\" v, backupFolder "\_Additional Assets\proj dirs\" v),, "hide")
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
        try cmd.run(,,, Format('Robocopy "{1}" "{2}" *.* /MIR /R:1', v, backupFolder "\_Additional Assets\videos\" dirName),, "hide")
    }
}

Notify.Show(, 'Your project is being backed up!', 'C:\Windows\System32\imageres.dll|icon249', 'Windows Battery Critical',, 'dur=5 bc=Black show=Fade@250 hide=Fade@250 bdr=Yellow tag=backupProjPreAlert maxW=400')
__doBackup(backupFolder, additionalDir)
if !DirExist(sd.backupFolderWork)
    return
backupFolder := sd.backupFolderWork
__doBackup(backupFolder, additionalDir)
if Notify.Exist("backupProjPreAlert")
    Notify.Destroy("backupProjPreAlert")
Notify.Show(, 'Your project has finished copying to the backup location!`nDon`'t forget to wait for any uploading processes', 'C:\Windows\System32\imageres.dll|icon281', 'Windows Print complete',, 'dur=4 bc=Black show=Fade@250 hide=Fade@250 bdr=Green maxW=400')
