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
commsFolder    := SubStr(projFolder.dir, 1, InStr(projFolder.dir, "\",, -1)) "videos"
outputFileName := "output_temp_file"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264
URL := ytdlp().download(Format('-N 8 --output "{}{}"', outputFileName, index := ytdlp().__getIndex("output_temp_file", commsFolder)), commsFolder)
if !URL
    return
switch InStr(URL, "twitch.tv") {
    case 0: ytdlp().reencode(commsFolder "\" outputFileName index, getHTMLTitle(URL))
    default:
        newName := getHTMLTitle(URL)
        newIndex := (getind := ytdlp().__getIndex(newName, commsFolder) = 0) ? "" : getind
        FileMove(commsFolder "\" outputFileName index, commsFolder "\" newName newIndex ".mp4")
        return
}