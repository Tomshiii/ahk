#SingleInstance Off
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\ytdlp>
#Include <Classes\winGet>
; }

if !WinExist(editors.Premiere.winTitle) && !WinExist(Editors.ae.winTitle)
    return

storedClip := A_Clipboard

;// getting proj path from prem/ae
if !projFolder := WinGet.ProjPath()
    return

;// I keep my project files buried in an extra folder so this string manipulation is to simply step back in the folder tree
sfxFolder    := SubStr(projFolder.dir, 1, InStr(projFolder.dir, "\",, -1)) "audio"

ytdlp().download(Format('-N 8 -o "{1}" --verbose --windows-filenames --extract-audio --audio-format wav', "{}"), sfxFolder, storedClip)