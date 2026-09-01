; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

paths := []
nPath := FileSelect("D2", "N:\The Boys Main", "Choose Directory to copy to")
if !nPath
    return

command := ""
for v in paths {
    SplitPath(v, &fileName,, &ext)
    folderPos := InStr(v, ".ARCHIVE VIDEOS (Do Not Delete!!!!)")
    slash1 := InStr(v, "\",, folderPos, 1)
    slash2 := InStr(v, "\",, folderPos, 2)
    startDir := nPath ((SubStr(nPath, -1, 1) = "\") ? "" : "\")
    dirName := startDir SubStr(v, slash1+1, slash2-slash1-1)
    if FileExist(dirName "." ext)
        continue
    command := rclone.formatCommand(dirName "." ext, v, 2)
    cmd.run(false, false, false, command,, "Hide")
}