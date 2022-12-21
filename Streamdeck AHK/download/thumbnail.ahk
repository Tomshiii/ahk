; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
#Include <Classes\winget>
#Include <Classes\ptf>
; }

;// if ae/premiere is open, it can extract the client name from the dir path in the title
;// otherwise it will default to "Other"
ClientName := (WinExist(Editors.Premiere.winTitle) || WinExist(Editors.AE.winTitle)) ? WinGet.ProjClient() : "Other"
downloadFolder := ptf.comms "\" ClientName "\thumbnails"
if !DirExist(downloadFolder)
    DirCreate(downloadFolder)
ytDownload("--write-thumbnail --skip-download", downloadFolder)