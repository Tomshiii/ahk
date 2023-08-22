#SingleInstance Off
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\ytdlp>
; }

if !WinExist(editors.Premiere.winTitle) && !WinExist(Editors.ae.winTitle)
    return

;// getting proj path from prem/ae
if !projFolder := WinGet.ProjPath()
    return
;// I keep my project files buried in an extra folder so this string manipulation is to simply step back in the folder tree
sfxFolder    := SubStr(projFolder.dir, 1, InStr(projFolder.dir, "\",, -1)) "audio"

ytdlp().download("-N 8 --extract-audio --audio-format wav", sfxFolder)