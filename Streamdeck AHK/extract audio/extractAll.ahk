#SingleInstance Off
; { \\ #Includes
#Include <Classes\ffmpeg>
#Include <Classes\cmd>
#Include <Classes\tool>
#Include <Classes\winGet>
; }

defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""
if !selectedFile := FileSelect("D 3", defaultDir, "Select file to extract audio.")
    return

;// checking to see if the user has [Bulk Audio Extract Tool](https://github.com/TimeTravelPenguin/BulkAudioExtractTool) installed
checkBaet := cmd.result('powershell -c "Get-Command -Name baet -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
if checkBaet != "" {
    cmd.run(,, 1, Format('baet extract dir -i "{1}"', WinGet.pathU(selectedFile)))
    return
}

;// creating an instance like this stops the script from producing a traytip for every audio stream
;// that it extracts
ffmpegInstance := ffmpeg()

filepaths := []
loop files selectedFile "\*", "F" {
    if A_LoopFileExt = "mp4" || A_LoopFileExt = "mkv"
        filepaths.Push(A_LoopFileFullPath)
}

tool.Tray({text: "This script will flash a cmd window for every file it is about to operate on", title: "Gathering frequency response of every audio stream", options: 0x1}, 2000)
command := ""
for v in filepaths {
    audioStreams := ffmpegInstance.__getFrequency(v)
    baseCommand  := ffmpegInstance.__baseCommandExtract(v)
    append       := (A_Index != filepaths.Length) ? "&&" A_space : ""
    command      := command baseCommand A_space ffmpegInstance.__buildExtractCommand(v, audioStreams.amount, audioStreams.hzArr) append
}

cmd.run(,,, command)
;// calls the traytip
ffmpegInstance.__Delete()