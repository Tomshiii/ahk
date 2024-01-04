#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\Streamdeck_opt>
; }

SDopt := SD_Opt()
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", SDopt.filenameLengthLimit)

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdlp().download(Format('-N 8 -o "{1}" --windows-filenames --extract-audio --audio-format wav', outputFileName), SDopt.sfxFolder)