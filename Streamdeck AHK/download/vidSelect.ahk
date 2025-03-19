#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
#Include <Classes\Streamdeck_opt>
#Include <Functions\useNVENC>
; }

storedClip := A_Clipboard
clip.copyWait(storedClip)
if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

SDopt := SD_Opt()

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264

;// determine whether nvenc is possible (this is a rudimentary check and might not be bulletproof, remove if you encounter issues)
encoder := (useNVENC() = true) ? SDopt.defaultNVENCencode : ""

ytdl := ytdlp()
ytdl.download(Format(ytdl.defaultVideoCommand, "{}", encoder), WinGet.pathU(selectedDir), storedClip)