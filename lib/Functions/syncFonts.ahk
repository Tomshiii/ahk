; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\notifyExt.ahk
; }

;// this entire script is ai generated. Use at your own risk

try path := A_Args[1]
if !IsSet(path)
    return

global fontState := {dc: 0, cb: 0, pendingNotify: false}
OnExit(fontCleanup)
notifyExt.showIfNotExist('installingFonts',, "Checking for fonts to sync in directory:`n" path, 'C:\Windows\System32\imageres.dll|icon119',,, "dur=5 pos=BR theme=Dark bdr=Teal show=Fade@250 hide=Fade@250 maxW=400")
r := installMissingFonts(path)

installedFaces() {
    faces := Map(), faces.CaseSense := false
    families := Map()
    pass := 1

    enumProc(lpelfe, lpntme, fontType, lParam) {
        if pass = 1 {
            fam := StrGet(lpelfe + 28, 32, "UTF-16")        ; LOGFONTW.lfFaceName
            if fam != "" && SubStr(fam, 1, 1) != "@"
                families[fam] := true
        } else {
            full := StrGet(lpelfe + 92, 64, "UTF-16")       ; elfFullName
            if full != "" && SubStr(full, 1, 1) != "@"
                faces[full] := true
        }
        return 1
    }

    lf := Buffer(92, 0)
    NumPut("UChar", 1, lf, 23)
    fontState.cb := CallbackCreate(enumProc, "F", 4)
    fontState.dc := DllCall("GetDC", "Ptr", 0, "Ptr")
    try {
        DllCall("EnumFontFamiliesExW", "Ptr", fontState.dc, "Ptr", lf, "Ptr", fontState.cb, "Ptr", 0, "UInt", 0)
        pass := 2
        for fam in families {
            StrPut(fam, lf.Ptr + 28, 32, "UTF-16")
            DllCall("EnumFontFamiliesExW", "Ptr", fontState.dc, "Ptr", lf, "Ptr", fontState.cb, "Ptr", 0, "UInt", 0)
        }
    } finally
        releaseFontHandles()
    return faces
}
fontFullNames(path) {
    be16(b, o) => (NumGet(b, o, "UChar") << 8) | NumGet(b, o + 1, "UChar")
    be32(b, o) => (be16(b, o) << 16) | be16(b, o + 2)

    names := []
    try f := FileOpen(path, "r")
    catch
        return names

    hdr := Buffer(12, 0)
    f.RawRead(hdr, 12)
    bases := []
    if StrGet(hdr, 4, "CP0") = "ttcf" {              ; collection: several faces
        n := be32(hdr, 8)
        dir := Buffer(n * 4)
        f.RawRead(dir, n * 4)
        loop n
            bases.Push(be32(dir, (A_Index - 1) * 4))
    } else
        bases.Push(0)

    for base in bases {
        f.Pos := base
        h := Buffer(12, 0), f.RawRead(h, 12)
        numTables := be16(h, 4)
        tbl := Buffer(numTables * 16)
        f.RawRead(tbl, numTables * 16)

        nameOff := nameLen := 0
        loop numTables {
            o := (A_Index - 1) * 16
            if StrGet(tbl.Ptr + o, 4, "CP0") = "name" {
                nameOff := be32(tbl, o + 8), nameLen := be32(tbl, o + 12)
                break
            }
        }
        if !nameOff
            continue

        f.Pos := nameOff
        nt := Buffer(nameLen, 0), f.RawRead(nt, nameLen)
        count := be16(nt, 2), strOff := be16(nt, 4)

        best := ""
        loop count {
            r := 6 + (A_Index - 1) * 12
            if be16(nt, r) != 3 || be16(nt, r + 6) != 4      ; Windows platform, nameID 4
                continue
            s := ""
            len := be16(nt, r + 8), off := strOff + be16(nt, r + 10)
            loop len // 2
                s .= Chr(be16(nt, off + (A_Index - 1) * 2))
            if be16(nt, r + 4) = 0x409 {                      ; prefer en-US
                best := s
                break
            }
            if best = ""
                best := s
        }
        if best != ""
            names.Push(best)
    }
    f.Close()
    return names
}
installMissingFonts(dir, allUsers := false) {
    faces := installedFaces()
    installed := [], skipped := 0, unreadable := []

    loop files, dir "\*.*", "R" {
        if !RegExMatch(A_LoopFileName, "i)\.(ttf|otf|ttc)$")
            continue

        names := fontFullNames(A_LoopFileFullPath)
        if !names.Length {                       ; couldn't parse, so report it rather than guess
            unreadable.Push(A_LoopFileFullPath)
            continue
        }
        if FileExist(EnvGet("LOCALAPPDATA") "\Microsoft\Windows\Fonts\" A_LoopFileName) {
            skipped++
            continue
        }

        missing := false
        for n in names
            if !faces.Has(n)
                missing := true
        if !missing {
            skipped++
            continue
        }

        try {
            print(A_LoopFileName " wanted: " names[1])
            installFont(A_LoopFileFullPath, allUsers)
            installed.Push(A_LoopFileName)
            for n in names
                faces[n] := true
        } catch as err {
            errorLog(err)
        }
    }
    if installed.Length
        notifyFontChange()
    return {installed: installed, skipped: skipped, unreadable: unreadable}
}
; tell running apps the font list changed (call once after a batch)
notifyFontChange() {
    DllCall("SendMessageTimeoutW", "Ptr", 0xFFFF, "UInt", 0x1D, "Ptr", 0, "Ptr", 0
          , "UInt", 2, "UInt", 1000, "UPtr*", &res := 0)
    fontState.pendingNotify := false
}
installFont(path, allUsers := false) {
    SplitPath(path, &fileName, , &ext, &baseName)
    if allUsers {
        if !A_IsAdmin
            throw Error("Installing for all users needs an elevated script", -1)
        destDir := A_WinDir "\Fonts", regRoot := "HKLM", regData := fileName
    } else {
        destDir := EnvGet("LOCALAPPDATA") "\Microsoft\Windows\Fonts", regRoot := "HKCU"
    }
    DirCreate(destDir)
    dest := destDir "\" fileName
    if !FileExist(dest)
        FileCopy(path, dest)
    if !allUsers
        regData := dest
    fontType := (ext = "otf") ? "OpenType" : "TrueType"
    RegWrite(regData, "REG_SZ"
           , regRoot "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
           , baseName " (" fontType ")")
    DllCall("gdi32\AddFontResourceW", "WStr", dest)   ; make it usable in this session
    fontState.pendingNotify := true
    return dest
}

releaseFontHandles() {
    if fontState.cb {
        CallbackFree(fontState.cb)
        fontState.cb := 0
    }
    if fontState.dc {
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", fontState.dc)
        fontState.dc := 0
    }
}

fontCleanup(exitReason, exitCode) {
    releaseFontHandles()
    if fontState.pendingNotify
        notifyFontChange()
    return 0   ; let the script exit
}