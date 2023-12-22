#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
; }

SDopt := SD_Opt()
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", SDopt.filenameLengthLimit)

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264
ytdlp().download(Format('-N 8 -o "{1}" --windows-filenames --recode-video mp4', outputFileName), SDopt.commsFolder)