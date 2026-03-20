cleanUpInstall(rootDir) {
    ;// these files will still be stored in their respective repos and can be downloaded manually
    ;// deleting these files saves close to 10mb for the final release

    ;// these functions is simply a wrapper to save lines & visual clutter
    ;// deleting psd files
    loop files rootDir "\*", "F R" {
        if A_LoopFileExt = "psd" ;they're large and unnecessary to include
            FileDelete(A_LoopFileFullPath)
    }
    ;// deleting the repo banner image
    checkFileDelete(rootDir "\Support Files\images\repo_social.png")
    ;// deleting the `old` wiki folder
    checkDirDelete(rootDir "\Backups\Wiki\Old")
    ;// deleting qmk images folder
    checkDirDelete(rootDir "\Support Files\qmk keyboard images")
    ;// deleting the `RODECaster` backup folder
    checkDirDelete(rootDir "\Backups\RODECaster")
    ;// deleting the `GoXLR` backup folder
    checkDirDelete(rootDir "\Backups\GoXLR Backups")
    ;// deleting the `Old Code` backup folder
    checkDirDelete(rootDir "\Backups\Old Code")
    ;// deleting the `VSCode` backup folder
    checkDirDelete(rootDir "\Backups\VSCode")
    ;// deleting the full res images
    checkDirDelete(rootDir "\Support Files\images\og")
    ;// deleting folder I store in repo that isn't needed
    checkDirDelete(rootDir "\Backups\Old Code\Stream\TomSongQueueue")
    ;// deleting vscode config folder
    checkDirDelete(rootDir "\.vscode")
    ;// resetting `values.ini` file so it's empty for the user
    checkFileDelete(rootDir "\Support Files\UIA\values.ini")
    FileAppend("{`n`n}", rootDir "\Support Files\UIA\values.ini")
}

checkDirDelete(dir) {
    if DirExist(dir)
        DirDelete(dir, 1)
}
checkFileDelete(file) {
    if FileExist(file)
        FileDelete(file)
}