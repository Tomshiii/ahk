#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
; }

sfxFolder := "E:\_Editing stuff\sfx"
;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"

ytdlp().download("-N 8 --extract-audio --audio-format wav", sfxFolder)