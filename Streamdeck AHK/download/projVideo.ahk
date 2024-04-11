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

;// I keep my project files buried in an extra folder so this string manipulation is to simply step back in the folder tree
commsFolder    := SubStr(projFolder.dir, 1, InStr(projFolder.dir, "\",, -1)) "videos"
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", SDopt.filenameLengthLimit)

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264
ytdlp().download(Format('-N 8 -o "{1}" --verbose --windows-filenames --recode-video mp4', outputFileName), commsFolder)