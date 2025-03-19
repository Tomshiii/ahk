#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
; }

storedClip := A_Clipboard
if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdl := ytdlp()
ytdl.download(Format(ytdl.defaultAudioCommand, "{}"), WinGet.pathU(selectedDir), storedClip)