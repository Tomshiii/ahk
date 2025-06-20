#Include <Classes\ptf>
#Include <Functions\unzip>
#Include <Classes\winGet>

;// downloads and installs; https://github.com/sebinside/HotkeylessAHK

downloadURl      := "https://github.com/sebinside/HotkeylessAHK/archive/refs/heads/main.zip"
streamdeckPlugin := A_AppData "\Elgato\StreamDeck\Plugins\"
dlLocation := WinGet.pathU(ptf.rootDir "\..\")

Download(downloadURl, dlLocation "hotkeylessExtract.zip")
;// unzip
unzip(dlLocation "hotkeylessExtract.zip", dlLocation ".hotkeylessExtract\")
dirName := ""
loop files dlLocation "\.hotkeylessExtract\*", "D" {
    DirMove(A_LoopFileFullPath, dlLocation A_LoopFileName)
    dirName := A_LoopFileName
}

;// remove old files/dir
FileDelete(dlLocation "hotkeylessExtract.zip")
DirDelete(dlLocation ".hotkeylessExtract", 1)

cmd.run(,,, "npm i", dlLocation dirName "\files")

DirMove(dlLocation dirName "\stream-deck-plugin\de.sebinside.hotkeylessahk.sdPlugin", streamdeckPlugin "de.sebinside.hotkeylessahk.sdPlugin", 1)
