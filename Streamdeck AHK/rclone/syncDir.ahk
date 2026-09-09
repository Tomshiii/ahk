; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\clip.ahk
#Include Classes\cmd.ahk
; }

nPath := FileSelect("D2", "N:\The Boys Main", "Choose Directory to copy from")
if !nPath
    return
SplitPath(nPath, &nFold)
prevClip := clip.clear()
A_Clipboard := nFold
gPath := FileSelect("D2", "G:\Shared drives\The Boys\2. Videos\1. The Boys", "Choose Directory to copy to (" nPath ")")
clip.returnClip(prevClip)
if !gPath
    return
command := rclone.formatCommand(nPath, gPath, 1)
cmd.run(false, false, false, command,, "Hide")
ExitApp()