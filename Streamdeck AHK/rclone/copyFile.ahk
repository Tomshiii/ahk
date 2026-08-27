; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
; }

gPath := FileSelect("1", "G:\Shared drives\The Boys\2. Videos\1. The Boys", "Choose file to copy")
if !gPath
    return
nPath := FileSelect("D2", "N:\The Boys Main", "Choose Directory to copy to")
if !nPath
    return
SplitPath(gPath, &fileName)
command := rclone.formatCommand(nPath "\" filename, gPath, 2)
cmd.run(false, false, false, command,, "Hide")