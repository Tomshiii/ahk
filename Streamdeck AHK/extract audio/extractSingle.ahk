#SingleInstance Off
; { \\ #Includes
#Include <Classes\ffmpeg>
#Include <Classes\explorer>
; }

defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? explorer.getPath() : ""
if !selectedFile := FileSelect(3, defaultDir, "Select file to extract audio.")
    return

ffmpeg().extractAudio(selectedFile)