; { \\ #Includes
#Include <Classes\ffmpeg>
; }

if !selectedFile := FileSelect(3,, "Select file to extract audio.")
    return

ffmpeg().extractAudio(selectedFile)