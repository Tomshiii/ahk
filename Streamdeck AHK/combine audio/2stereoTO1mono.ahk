#SingleInstance Off
; { \\ #Includes
#Include <Classes\ffmpeg>
#Include <Classes\cmd>
#Include <Classes\tool>
#Include <Classes\obj>
#Include <Classes\winGet>
; }

;//! THIS SCRIPT IS NOT MEANT FOR GENERAL PURPOSE
;//! IT IS SPECIFICALLY DESIGNED TO COMBINE TWO LAV FILES (same audio, different gain levels) INTO ONE
;//! ONE OF OUR LAV FILES ENDS IN '_D' WHICH DENOTES THE DIFFERENCE
;//! THIS CODE WILL NOT WORK UNLESS THAT CONDITION IS MET

;//* This script will only check the first file in the directory to determine if all files are mono/stereo
;//* the final ffmpeg command is different depending on which it is so make sure not to mix different files into this process

recurse := (MsgBox("Do you wish to recurse?", "Recurse?", "4 32 4096") = "Yes") ? "R" : ""

defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""
if !selectedFile := FileSelect("D 3", defaultDir, "Select file to extract audio.")
    return

;// creating an instance like this stops the script from producing a traytip for every audio stream
;// that it extracts
ffmpegInstance := ffmpeg()

filepaths := []
loop files selectedFile "\*", "F" recurse {
    if A_LoopFileExt != "mp3" && A_LoopFileExt != "wav"
        continue
    fileObj := obj.SplitPath(A_LoopFileFullPath)
    if SubStr(fileObj.NameNoExt, -2) = "_D"
        continue
    if !FileExist(fileObj.dir "\" fileObj.NameNoExt "_D." fileObj.ext)
        continue
    if FileExist(fileObj.dir "\" fileObj.NameNoExt "_combined." fileObj.ext) {
        if MsgBox("File: " fileObj.NameNoExt "_combined." fileObj.ext "`nAlready exists, would you like to ignore and continue?`n`nDoing so could cause ffmpeg to run into issues", "Abort or Continue?", "4 32 4096") = "No"
            return
        continue
    }
    filepaths.Push(A_LoopFileFullPath)
}

if filepaths.Length < 1 {
    ;// throw
    errorLog(UnsetError("No files found.", -1),,, 1)
}

command := ""
for v in filepaths {
    if !channels := ffmpegInstance.__getChannels(filepaths[1]) {
        ;// throw
        errorLog(UnsetError("Unable to determine channels for file.", -1), "File may be corrupted or not contain any audio streams",, 1)
    }

    switch channels {
        ;// if mono
        case "1": baseCommand := 'ffmpeg -i "{1}" -i "{2}" -filter_complex "[0:a][1:a]join=inputs=2:channel_layout=stereo[a]" -map "[a]" "{3}"'
        ;// if stereo
        case "2": baseCommand := 'ffmpeg -i "{1}" -i "{2}" -filter_complex "[0:a][1:a]amerge=inputs=2,pan=stereo|c0<c0+c1|c1<c2+c3[a]" -map "[a]" "{3}"'
        default:
            ;// throw
            errorLog(UnsetError("An undefined amount of channels was found in the audio file.", -1),,, 1)
            ffmpegInstance.__Delete()
            ExitApp()
    }
    fileObj   := obj.SplitPath(v)
    append    := (A_Index != filepaths.Length) ? "&&" A_space : ""
    currentOp := Format(baseCommand, v, fileObj.dir "\" fileObj.NameNoExt "_D." fileObj.ext, fileObj.dir "\" fileObj.NameNoExt "_combined." fileObj.ext)
    command   := command currentOp A_Space append
}

cmd.run(,,, command)
;// calls the traytip
ffmpegInstance.__Delete()