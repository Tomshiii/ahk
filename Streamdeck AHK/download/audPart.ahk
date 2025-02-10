#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winGet>
#Include <GUIs\partDL>
; }

storedClip := A_Clipboard
clip.copyWait(storedClip)
if !selectedDir := FileSelect("D2",, "Select Download Location")
    return

timecode := partDL()
if !timecode.value
    return
timecode.__Delete()

A_Clipboard := storedClip
;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"
ytdlp().download(Format('-N 8 -o "{1}" --download-sections "*{2}" --verbose --windows-filenames --extract-audio --audio-format wav', "{}", timecode.value), WinGet.pathU(selectedDir))