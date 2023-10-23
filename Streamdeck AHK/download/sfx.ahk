#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_ptf>
; }

SDptf := SD_ptf()
;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"

ytdlp().download("-N 8 --extract-audio --audio-format wav", SDptf.sfxFolder)