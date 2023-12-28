; { \\ #Includes
#Include <Classes\cmd>
#Include <Classes\obj>
; }

;// this script will convert an mp3 => wav or wav => mp3
;// the files path must be in the clipboard
path := obj.SplitPath(StrReplace(A_Clipboard, '"', ""))
opposite := (path.ext = "mp3") ? "wav" : "mp3"
command := Format('ffmpeg -i "{}" "{}"', path.path, path.dir "\" path.NameNoExt "." opposite)
cmd.run(,,, command)