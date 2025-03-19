#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
; }

SDopt := SD_Opt()
if !DirExist(SDopt.sfxFolder)
    return
storedClip := A_Clipboard

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdl := ytdlp()
ytdl.download(Format(ytdl.defaultAudioCommand, "{}"), SDopt.sfxFolder, storedClip)