#SingleInstance Off
; { \\ #Includes
#Include <Classes\ytdlp>
#Include <Classes\winget>
#Include <Classes\ptf>
; }

;// if ae/premiere is open, it can extract the client name from the dir path in the title
;// otherwise it will default to "Other"
ClientName := (WinExist(Editors.Premiere.winTitle) || WinExist(Editors.AE.winTitle)) ? WinGet.ProjClient() : "Other"
;// `口` will place the folder at the bottom of the list if you sort folders by name
downloadFolder := ptf.comms "\" ClientName "\口 thumbnails"
if !DirExist(downloadFolder)
    DirCreate(downloadFolder)
ytdlp().download("--write-thumbnail --skip-download", downloadFolder)
;// ;yt-dlp --write-thumbnail --skip-download -P "link\to\path" "URL"