
onPath(name) {
    exts := [""]
    for e in StrSplit(EnvGet("PATHEXT") || ".COM;.EXE;.BAT;.CMD", ";")
        if e != ""
            exts.Push(e)
    for dir in StrSplit(EnvGet("PATH"), ";", " `t`"") {
        if dir = ""
            continue
        for ext in exts
            if (a := FileExist(dir "\" name ext)) && !InStr(a, "D")
                return true
    }
    return false
}