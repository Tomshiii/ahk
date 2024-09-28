; { \\ #Includes
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Classes\winget>
; }

;// this script will convert an mp3 => wav or wav => mp3

activeWin := WinGet.ExplorerPath()
defaultDir := activeWin != false ? activeWin : ""
selectFile := FileSelect("3", defaultDir, "Select the .mp3 or .wav file you wish to convert.")
if selectFile = ""
    return

path := obj.SplitPath(selectFile)
opposite := (path.ext = "mp3") ? "wav" : "mp3"
command := Format('ffmpeg -i "{}" "{}"', path.path, path.dir "\" path.NameNoExt "." opposite)
cmd.run(,,, command)