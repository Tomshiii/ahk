#Include <Classes\tool>
#Include <Classes\obj>

; // not necessarily an "old" script, just one I used to clean up some directories on my NAS
; this isn't clean code at all, and some lines may seem redundant, I just wanted to be extra sure things wouldn't go wrong

maxFileSizeGB := 2
check := MsgBox(A_ScriptDir "`nIs this script in the directory you'd like to check?", "Double Check", "4 32 256 4096")
if check = "No"
    return
loop files, A_ScriptDir "\*.*", "F R"
    {
        loops := obj.SplitPath(A_LoopFileFullPath)
        tool.Cust(loops.dir)
        ;maybe this needs to be something like a_loopfile in dir etc etc idk figure it out
        if !InStr(loops.dir, "\videos")
            continue
        if InStr(loops.dir, "\renders") ;double check
            continue
        if A_LoopFileSize/1073741824 > maxFileSizeGB
            FileDelete(A_LoopFileFullPath)
        else
            continue
    }