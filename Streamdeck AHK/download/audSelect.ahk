#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
; }

if !selectedDir := FileSelect("D2",, "Select Download Location")
    return
;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"

ytdlp().download("-N 8 --extract-audio --audio-format wav", selectedDir "\")