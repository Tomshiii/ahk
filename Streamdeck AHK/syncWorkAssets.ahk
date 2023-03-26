; { \\ #Includes
#Include <Classes\ptf>
#Include <Other\print>
#Include <Other\JSON>
; }

;// this script is designed to allow easy syncing between work and home asset folders

;// select work folder
workDir := FileSelect("D",, "Select Work Asset Folder")
if workDir = ""
    return
;// set home dir
homeDir := ptf.EditingStuff
;// define folders
folders := ["Images", "sfx", "videos"]
;// set maps
failed := Map()
homeFiles := Map()
workFiles := Map()

/**
 * function to generate maps used in script
 * @param {String} dir the dir the loop will parse through
 * @param {Map} map a previously generated map to add to
 */
setMap(dir, map?) {
    loop files dir, "F" {
        map.Set(A_LoopFileName, A_LoopFileFullPath)
        print(A_LoopFileName " -- " A_LoopFileFullPath)
    }
    return map
}

for folder in folders {
    homeFiles := setMap(homeDir "\" folder "\*", homeFiles)
    workFiles := setMap(workDir "\" folder "\*", workFiles)

    copyOneWay(homeFiles, workFiles, workDir, folder)
    copyOneWay(workFiles, homeFiles, homeDir, folder)
    homeFiles.Clear()
    workFiles.Clear()
}

/**
 * @param {Map} arr a dupe of the map you wish to work on
 * @param {Map} oppositeArr the original map of the opposite dir
 * @param {String} oppositeDir the directory of the opposite map
 * @param {String} whichFolder the name of the folder currently being worked on
 */
copyOneWay(arr, oppositeArr, oppositeDir, whichFolder) {
    cloneArr := arr.Clone()
    cloneOpp := oppositeArr.Clone()
    for filename, path in arr {
        if cloneOpp.Has(filename) {
            cloneArr.Delete(filename)
            print("deleting: " filename)
        }
    }

    if cloneArr.Count != 0 {
        for filename, path in cloneArr {
            try {
                print("copying: " path " to: " oppositeDir "\" whichFolder "\" filename)
                FileCopy(path, oppositeDir "\" whichFolder "\" filename, 1)
                oppositeArr.Set(filename, oppositeDir "\" whichFolder "\" filename)
            } catch {
                failed.Set(filename, path)
                print("failed: " filename " -- " path)
            }
        }
    }
}

if failed.Count != 0 {
    if !DirExist(A_Temp "\tomshi")
        DirCreate(A_Temp "\tomshi")
    if FileExist(A_Temp "\tomshi\failed.txt")
        FileDelete(A_Temp "\tomshi\failed.txt")
    for filename, path in failed {
        FileAppend("file: " filename "`npath: " path "`n`n", A_Temp "\tomshi\failed.txt")
    }
    Run(A_Temp "\tomshi\failed.txt")
}