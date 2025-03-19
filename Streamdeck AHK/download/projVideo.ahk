#SingleInstance Off
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
#Include <Classes\winGet>
#Include <Functions\useNVENC>
; }

if !WinExist(editors.Premiere.winTitle) && !WinExist(Editors.ae.winTitle)
    return
storedClip := A_Clipboard

;// getting proj path from prem/ae
if !projFolder := WinGet.ProjPath()
    return

SDopt := SD_Opt()

;// I keep my project files buried in an extra folder so this string manipulation is to simply step back in the folder tree
commsFolder    := SubStr(projFolder.dir, 1, InStr(projFolder.dir, "\",, -1)) "videos"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264

;// determine whether nvenc is possible (this is a rudimentary check and might not be bulletproof, remove if you encounter issues)
encoder := (useNVENC() = true) ? SDopt.defaultNVENCencode : ""

ytdl := ytdlp()
ytdl.download(Format(ytdl.defaultVideoCommand, "{}", encoder), commsFolder, storedClip)