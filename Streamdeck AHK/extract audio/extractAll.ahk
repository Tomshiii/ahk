#SingleInstance Off
; { \\ #Includes
#Include <Classes\ffmpeg>
; }

if !selectedFile := FileSelect("D 3",, "Select file to extract audio.")
    return

filepaths := []
loop files selectedFile "\*", "F" {
    if A_LoopFileExt = "mp4" || A_LoopFileExt = "mkv"
        filepaths.Push(A_LoopFileFullPath)
}
for v in filepaths {
    ffmpeg().extractAudio(v)
}