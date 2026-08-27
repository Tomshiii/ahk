; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
; }

paths := ["G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\230. Asylum Sam & Colby\230. Sam & Colby final.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\265. Haunted Hill House\Final Renders\_cut.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\240. Haunted Jail ft. MoistCr1TiKaL\FINALFAINAL.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\152. Old people Roast The Boys\152. The Roast of The Boys.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\133. Hasbulla Meet\133. Hasbulla Interview.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\135. USA Camping\135. The Boys Go Camping (USA EDITION).mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\165. Deep Fry\The Boys Deep Fry EVERYTHING v3.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\231. Try not to move challenge\CUT.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\284. You Move… You Lose 2.0\FINALS\You Move... You Lose.. 2.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\227. Mario Party\CUT.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\266. Mario Party 2\_Final Renders\CUT.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\171. $100 VS 10K Day In Tokyo\100 vs 10000 Day japan v1.mp4", "G:\Shared drives\The Boys\2. Videos\1. The Boys\.ARCHIVE VIDEOS (Do Not Delete!!!!)\125. Hottest Ramen 2.0\125.HottestRamen2.mp4"]
nPath := FileSelect("D2", "N:\The Boys Main", "Choose Directory to copy to")
if !nPath
    return

command := ""
for v in paths {
    SplitPath(v, &fileName)
    folderPos := InStr(v, ".ARCHIVE VIDEOS (Do Not Delete!!!!)")
    slash1 := InStr(v, "\",, folderPos, 1)
    slash2 := InStr(v, "\",, folderPos, 2)
    startDir := nPath ((SubStr(nPath, -1, 1) = "\") ? "" : "\")
    dirName := startDir SubStr(v, slash1+1, slash2-slash1-1)
    /* if !DirExist(dirName)
        DirCreate(dirName) */
    command := rclone.formatCommand(startDir dirName, v, 2)
    cmd.run(false, false, false, command,, "Hide")
}