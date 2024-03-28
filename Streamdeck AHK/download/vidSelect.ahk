#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
; }

SendInput("^c")

if !selectedDir := FileSelect("D2",, "Select Download Location")
    return
filenameLengthLimit := 50
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", filenameLengthLimit)

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264
ytdlp().download(Format('-N 8 -o "{1}" --windows-filenames --recode-video mp4', outputFileName), WinGet.pathU(selectedDir))