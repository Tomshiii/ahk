#Include <Classes\Editors\Premiere>
#Include <Classes\winget>
#Include <Classes\Mip>

;// sometimes when dl'ing from frameio if it errors out or a file wasn't fully uploaded yet it'll leave an empty file behind which makes it difficult to then properlly download it later
;// this script will recurse a directory and delete any 0kb files.
;// BE VERY CAREFUL WITH THIS AS IT HAS LITTLE TO NO OTHER LOGIC

if WinExist(prem.winTitle) {
    try {
        path := WinGet.ProjPath()
        defaultDir := path.dir
    } catch {
        ;// same as below
        defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""
    }
}
else
    defaultDir := (WinActive("ahk_exe explorer.exe") && WinActive("ahk_class CabinetWClass")) ? WinGet.ExplorerPath(WinExist("A")) : ""

if !selectedDir := FileSelect("D", defaultDir, "Select Directory to recurse")
    return

if MsgBox("This process will recurse the selected directory and delete any files that are .mp4/.mov/.wav and are 0kb in size. This can be very dangerous if you are not careful`n`nDo you wish to continue?",, "0x4") = "No"
    return

acceptedFiles := Mip("mp4", true, "mov", true, "wav", true)
loop files selectedDir "\*", "FR" {
    if !acceptedFiles.Has(A_LoopFileExt)
        continue
    if A_LoopFileSizeKB != "0"
        continue

    ;// remove/comment out this if/else if you want to remove checks
    if MsgBox("File: " A_LoopFileFullPath "`nDo you wish to delete?",, "0x4") = "No"
        continue
    else
        FileDelete(A_LoopFileFullPath)
}