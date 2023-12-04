#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_ptf>
#Include <Functions\getHTMLTitle>
; }

SDptf := SD_ptf()
outputFileName := "output_temp_file"

;// I use these scripts to quickly download videos from youtube to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so I download the highest quality file and reencode it to h264
URL := ytdlp().download(Format('-N 8 --output "{}{}"', outputFileName, index := ytdlp().__getIndex("output_temp_file", SDptf.vfxFolder)), SDptf.vfxFolder)
if !URL
    return
ytdlp().reencode(SDptf.vfxFolder "\" outputFileName index, getHTMLTitle(URL))