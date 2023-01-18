#SingleInstance Off
; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
; }

sfxFolder := "E:\_Editing stuff\sfx"
;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"

ytDownload("--extract-audio --audio-format wav", sfxFolder)