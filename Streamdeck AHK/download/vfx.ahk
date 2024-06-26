#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
#Include <Functions\getHTMLTitle>
#Include <Functions\useNVENC>
; }

SDopt := SD_Opt()

;// I use these scripts to quickly download videos from youtube to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so I download the highest quality file and reencode it to h264

;// determine whether nvenc is possible (this is a rudimentary check and might not be bulletproof, remove if you encounter issues)
encoder := (useNVENC() = true) ? SDopt.defaultNVENCencode : ""

ytdlp().download(Format('-N 8 -o "{1}" --verbose --windows-filenames --recode-video mp4 {2}', "{}", encoder), SDopt.vfxFolder)