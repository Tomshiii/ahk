#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
#Include <Classes\Streamdeck_opt>
; }

SendInput("^c")

if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

timecode := InputBox("Please provide the timecode that all content you wish to download sits within.`n`nPlease use the format;`nhh:mm:ss-hh:mm:ss")
if timecode.result = "Cancel"
    return

SDopt := SD_Opt()
outputFileName := Format("%(title).{1}s [%(id)s].%(ext)s", SDopt.filenameLengthLimit)

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdlp().download(Format('-N 8 -o "{1}" --download-sections "*{2}" --verbose --windows-filenames --extract-audio --audio-format wav', outputFileName, timecode.value), WinGet.pathU(selectedDir))