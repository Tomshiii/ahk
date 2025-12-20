#SingleInstance Off
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ffmpeg.ahk
#Include Classes\explorer.ahk
; }

defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? explorer.getPath() : ""
if !selectedFile := FileSelect(3, defaultDir, "Select file to extract audio.")
    return

ffmpeg().extractAudio(selectedFile)