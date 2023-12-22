#SingleInstance Off
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
#Include <Classes\winGet>
; }

if !WinExist(editors.Premiere.winTitle) && !WinExist(Editors.ae.winTitle)
    return

;// getting proj path from prem/ae
if !projFolder := WinGet.ProjPath()
    return

SDopt := SD_Opt()
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", SDopt.filenameLengthLimit)

;// I keep my project files buried in an extra folder so this string manipulation is to simply step back in the folder tree
sfxFolder    := SubStr(projFolder.dir, 1, InStr(projFolder.dir, "\",, -1)) "audio"

ytdlp().download(Format('-N 8 -o "{1}" --windows-filenames --extract-audio --audio-format wav', outputFileName), sfxFolder)