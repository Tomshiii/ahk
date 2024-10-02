
/**
 * macOS creates annoying files with a ._ at the beginning this function removes them from a directory
 * @param {String} [dir=""] if you wish to define a directory for this function to operate on. Otherwise a selection window will prompt the user
 * @param {Boolean} [recurse=true] whether you wish for the function to recurse into further directories or not
 */
deleteDotUnderscore(dir := "", recurse := true) {
    if !dir || !DirExist(dir) {
        if !selectedDir := FileSelect("D2",, "Select Starting Dir - This Loop will Recurse")
            return
    } else {
        selectedDir := dir
    }

    /**
     * Delete some common reoccuring folders that appear in the root directory of a drive
     * @param {String} filename the name of the usually hidden file
     */
    __rootDirDelete(filename) {
        if DirExist(selectedDir "\" filename)
            DirDelete(selectedDir "\" filename, 1)
    }

    __rootDirDelete(".fseventsd")
    __rootDirDelete(".Spotlight-V100")
    __rootDirDelete(".TemporaryItems")
    __rootDirDelete(".Trashes")

    recurseDir := recurse = true ? "R" : ""
    loop files selectedDir "\*", "F" recurseDir {
        if (SubStr(A_LoopFileName, 1, 2) = "._" && FileGetSize(A_LoopFileFullPath, "K") = 4) || (A_LoopFileExt = "DS_Store")
            try FileDelete(A_LoopFileFullPath)
    }

}