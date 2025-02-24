#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
; }

storedClip := A_Clipboard
if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdlp().download(Format('-N 8 -o "{1}" --verbose --windows-filenames --extract-audio --audio-format wav', "{}"), WinGet.pathU(selectedDir), storedClip)