#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_ptf>
; }

SDptf := SD_ptf()
outputFileName := "output_temp_file"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264
URL := ytdlp().download(Format('-N 8 --output "{}{}"', outputFileName, index := ytdlp().__getIndex("output_temp_file", SDptf.commsFolder)), SDptf.commsFolder)
if !URL
    return
ytdlp().handleDownload(URL, SDptf.commsFolder, outputFileName, index)