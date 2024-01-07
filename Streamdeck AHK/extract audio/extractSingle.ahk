#SingleInstance Off
; { \\ #Includes
#Include <Classes\ffmpeg>
#Include <Classes\winget>
; }

defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""
if !selectedFile := FileSelect(3, defaultDir, "Select file to extract audio.")
    return

ffmpeg().extractAudio(selectedFile)