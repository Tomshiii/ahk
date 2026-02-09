#SingleInstance Force
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ffmpeg.ahk
; }

ffmpeg().all_XtoY("W:\REPO_Sounds-20251014T012517Z-1-001\REPO_Sounds", "ogg", "wav")

/* completed := Map()
inputDir := "W:\work\331. Rocket League IRL\audio\sfx\orig\EXTRACT_RocketLeagueAudio\EXTRACT_RocketLeagueAudio"
loop files inputDir "\*", "FR" {
    SplitPath(A_LoopFileFullPath, &name, &dir, &origExt, &nameNoExt)
    if origExt = "wav"
        continue
    if completed.Has(A_LoopFileFullPath)
        continue
    if FileExist(dir "\" nameNoExt ".wav")
        continue
    command := Format('ffmpeg -i "{1}" "{2}"', A_LoopFileFullPath, dir "\" nameNoExt ".wav")
    cmd.run(,,, command,, "Hide")
    if FileExist(A_LoopFileFullPath) && FileExist(dir "\" nameNoExt ".wav") {
        FileDelete(A_LoopFileFullPath)
        completed.Set(dir "\" nameNoExt "." origext, true)
        completed.Set(dir "\" nameNoExt ".wav", true)
    }
} */