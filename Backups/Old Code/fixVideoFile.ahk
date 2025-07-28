#Requires AutoHotkey v2.0
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Other\print>

;// this script requires the user to;
;// download mplayer - https://sourceforge.net/projects/mplayer-win32/ (make sure you grab the `/MPlayer and MEncoder` link, not the ffmpeg link like I did 3 times...)
;// extract to somewhere, easy choice is C:\ProgramData\chocolatey\lib\mplayer
;// add location to `Path` variable
;// reboot to refresh path variable - otherwise add `RefreshEnv && ` to the beginning of `fixCommand` (that command requries chocolatey to be installed however)
;// change below `rootDir`

rootDir := ""
fixCommand := 'mencoder "{1}" -ovc copy -oac copy -o "{2}"'

loop files rootDir "\*", "FR" {
    fileObj := obj.SplitPath(A_LoopFileFullPath)
    if fileObj.Ext != "avi" || InStr(fileObj.Dir, "fixed") || InStr(fileObj.NameNoExt, "_fixed") || FileExist(fileObj.dir "\fixed\" fileObj.NameNoExt "_fixed.avi") {
        print("skipping: " fileObj.NameNoExt)
        continue
    }
    if !DirExist(fileObj.Dir "\fixed")
        DirCreate(fileObj.Dir "\fixed")
    print("starting: " fileObj.NameNoExt)
    cmd.run(,,, Format(fixCommand, A_LoopFileFullPath, fileObj.dir "\fixed\" fileObj.NameNoExt "_fixed.avi"),, "Hide")
    print(fileObj.NameNoExt " complete")
}