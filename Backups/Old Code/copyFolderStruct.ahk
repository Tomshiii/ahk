if !folderLink := FileSelect("D3", "N:\The Boys Main", "Select folder to copy")
    return
if !gdriveLink := FileSelect("D3", "G:\Shared drives\The Boys\2. Videos\1. The Boys", "Select folder to copy to. (" folderLink ")")
    return
loop files folderLink "\*", "D" {
    DirCreate(gdriveLink "\" A_LoopFileName)
}