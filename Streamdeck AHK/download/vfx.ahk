#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
; }

vfxFolder := "E:\_Editing stuff\videos"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so I download the highest quality file and reencode it to h264
URL := ytdlp().download('-N 8 --output "output_temp_file"', vfxFolder)
if !URL
    return
ytdlp().reencode(vfxFolder "\output_temp_file", getHTMLTitle(URL))