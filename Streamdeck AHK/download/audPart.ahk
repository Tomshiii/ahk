#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
; }

SendInput("^c")

if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

timecode := InputBox("Please provide the timecode that all content you wish to download sits within.`n`nPlease use the format;`nhh:mm:ss-hh:mm:ss")
if timecode.result = "Cancel"
    return

;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdlp().download(Format('-N 8 -o "{1}" --download-sections "*{2}" --verbose --windows-filenames --extract-audio --audio-format wav', "{}", timecode.value), WinGet.pathU(selectedDir))