#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
; }

commsFolder := "E:\comms"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files or av1 files so if downloading from yt I download the highest quality file and reencode it to h264
URL := ytdlp().download('-N 8 --output "output_temp_file"', commsFolder)
if !URL
    return
switch InStr(URL, "twitch.tv") {
    case 0: ytdlp().reencode(commsFolder "\output_temp_file", getHTMLTitle(URL))
    default:
        newName := getHTMLTitle(URL)
        FileMove(commsFolder "\output_temp_file", commsFolder "\" newName ".mp4")
        return
}