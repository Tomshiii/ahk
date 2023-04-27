#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
; }

commsFolder := "E:\comms"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so I download the highest quality file and reencode it to h264
URL := ytdlp().download('--output "output_temp_file"', commsFolder)
if !URL
    return
ytdlp().reencode(commsFolder, getHTMLTitle(URL))