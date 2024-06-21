#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
#Include <Classes\Streamdeck_opt>
#Include <Functions\useNVENC>
; }
SendInput("^c")

if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

timecode := InputBox("Please provide the timecode that all content you wish to download sits within.`n`nPlease use the format;`nhh:mm:ss-hh:mm:ss")
if timecode.result = "Cancel"
    return

SDopt := SD_Opt()
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", SDopt.filenameLengthLimit)

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264

;// determine whether nvenc is possible (this is a rudimentary check and might not be bulletproof, remove if you encounter issues)
encoder := (useNVENC() = true) ? SDopt.defaultNVENCencode : ""

ytdlp().download(Format('-N 8 -o "{1}" --download-sections "*{3}" --verbose --windows-filenames --recode-video mp4 {2}', outputFileName, encoder, timecode.value), WinGet.pathU(selectedDir))