/**
 * returns the number of files & subdirectories in the given directory
 * @param {String} [dir] the directory you wish to check
 * @param {Boolean} [recurse=false] determines whether you wish to recurse in the chosen directory or not
 * @link https://www.autohotkey.com/boards/viewtopic.php?p=494290#p494290
 * @returns {Boolean/Object} returns boolean false if dir does not exist, else;
 *
 * `{files: {Integer}, subdirs: {Integer}}`
 */
nItemsInDir(dir, recurse := false) {
    if !DirExist(dir)
        return false
    objFolder := ComObject('Scripting.FileSystemObject').GetFolder(dir)
    files := objFolder.Files.Count, folders := objFolder.SubFolders.Count
    loop files recurse ? dir '\*' : '', 'DR'
        n := nItemsInDir(A_LoopFilePath), files += n.files, folders += n.subdirs
    return {files: files, subdirs: folders}
}