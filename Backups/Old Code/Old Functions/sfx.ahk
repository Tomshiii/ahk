;// attempt at sanitising filenames
#SingleInstance Off
; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
; }

sfxFolder := "E:\_Editing stuff\sfx"
;yt-dlp --extract-audio --audio-format wav -P "link\to\path" "URL"

url := ytDownload("--extract-audio --audio-format wav", sfxFolder)
getTitle := getHTMLTitle(url, false)
URLTitle := StrReplace(getTitle, " - YouTube", "") " [" SubStr(url, InStr(url, "watch?v=", 1,, 1) + 8) "]"
dummyTitle := URLTitle
fix := false
if !FileExist(sfxFolder "\" URLTitle ".wav") && !FileExist(sfxFolder "\" URLTitle ".mp3")
    return
MsgBox()
loop StrLen(URLTitle) {
    char := SubStr(URLTitle, A_Index, 1)
    if !IsAlnum(char) && !IsSpace(char) {
        dummyTitle := StrReplace(dummyTitle, char, "", 1,, 1)
        fix := true
    }
}
if fix {
    filetype := (FileExist(sfxFolder "\" URLTitle ".wav")) ? ".wav" : ".mp3"
    FileMove(sfxFolder "\" URLTitle, sfxFolder "\" dummyTitle filetype)
}