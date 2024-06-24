;// macOS creates annoying files with a ._ at the beginning
;// this loop hopes to delete them

if !selectedDir := FileSelect("D2",, "Select Starting Dir - This Loop will Recurse")
    return

/**
 * Delete some common reoccuring folders that appear in the root directory of a drive
 * @param {String} dirName the name of the usually hidden dir
 */
__rootDirDelete(dirName) {
    if DirExist(selectedDir "\" dirName)
        DirDelete(selectedDir "\" dirName, 1)
}

__rootDirDelete(".fseventsd")
__rootDirDelete(".Spotlight-V100")
__rootDirDelete(".TemporaryItems")
__rootDirDelete(".Trashes")

loop files selectedDir "\*", "FR" {
    if (SubStr(A_LoopFileName, 1, 2) = "._" && FileGetSize(A_LoopFileFullPath, "K") = 4) || (A_LoopFileExt = "DS_Store")
        try FileDelete(A_LoopFileFullPath)
}