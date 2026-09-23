; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\clip.ahk
#Include Classes\cmd.ahk
; }

try which := A_Args[1]
start := IsSet(which) ? (which = "1" ? "N:\The Boys Main" : "G:\Shared drives\The Boys\2. Videos\1. The Boys") : "N:\The Boys Main"
end := start = "N:\The Boys Main" ? "G:\Shared drives\The Boys\2. Videos\1. The Boys" : "N:\The Boys Main"
nPath := FileSelect("D2", start, "Choose Directory to copy from")
if !nPath
    return
SplitPath(nPath, &nFold)
prevClip := clip.clear()
A_Clipboard := nFold
gPath := FileSelect("D2", end, "Choose Directory to copy to (" nPath ")")
clip.returnClip(prevClip)
if !gPath
    return
command := rclone.formatCommand(nPath, gPath, which ?? "1")
cmd.run(false, false, false, command,, "Hide")
ExitApp()