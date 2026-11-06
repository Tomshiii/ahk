; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\obj.ahk
#Include Other\Notify\Notify.ahk
; }

/**
 * Mirrors one directory to another using Robocopy (`/MIR /R:1`), but only after verifying that both drives
 * are mounted and match the expected label and serial number, so the wrong drive is never mirrored over.
 *
 * Progress is shown in a `Notify` window. Clicking the window cancels the sync: the file currently being
 * copied is allowed to finish (so no partial files are left behind), then the remaining files are skipped
 * and the removal of extra files in `dest` is skipped too.
 *
 * Files are copied one Robocopy call at a time, so a cancel never interrupts a write. A dry run (`/L`)
 * first collects the list of files to copy; extras in `dest` are then removed in a final pass.
 *
 * Because `/MIR` is used, anything in `dest` that no longer exists in `src` is deleted.
 *
 * @param {Map} [dirsMap=unset] a map containing all the required information. Must be in the following style;
 * ```
Map(
    "src", {label: "", serial: , dirPath: ""},
    "dest", {label: "", serial: , dirPath: ""})
 * ```
 * where;
 * @param `"src"` acts as the source directory, `"dest"` acts as the destination directory
 * @param {String} [label] The name of the drive. Generally retrieved using `DriveGetLabel()`
 * @param {Integer} [serial] The serial number of the drive. Generally retrieved using `DriveGetSerial()`
 * @param {String} [dirPath] The directory you wish to sync from/too
 *
 * @returns {Boolean} `true` if the sync completed successfully (or there was nothing to do). `false` if either
 * directory doesn't exist, either drive isn't mounted or fails the label/serial check, the user cancelled,
 * or Robocopy reported an error (exit code 8 or higher, or the process failed to launch).
 *
 * @returns {Boolean}
 */
syncDirectories(dirsMap?) {
	myDirsMap := (!IsSet(dirsMap) || !IsObject(dirsMap) || !dirsMap.has("src") || !dirsMap.has("dest") || !dirsMap["dest"].HasOwnProp('label') || !dirsMap["dest"].HasOwnProp('serial') || !dirsMap["dest"].HasOwnProp('dirPath')) || !dirsMap["src"].HasOwnProp('label') || !dirsMap["src"].HasOwnProp('serial') || !dirsMap["src"].HasOwnProp('dirPath')
		? Map("src", {label: "Tom Work", serial: 3829588704, dirPath: "W:\_Assets"}, "dest", {label: "storage", serial: 489231902, dirPath: "N:\_Backups\Folder Backups\Tom Assets"})
		: dirsMap
	path := obj.SplitPath(myDirsMap["src"].dirPath)
	dest := obj.SplitPath(myDirsMap["dest"].dirPath)
	if !DirExist(path.path) || !DirExist(dest.path) {
		return false
	}

	getList := DriveGetList("FIXED") . DriveGetList("NETWORK")
	if InStr(getList, SubStr(path.Drive, 1, 1)) && InStr(getList, SubStr(dest.Drive, 1, 1)) {
		labelW  := DriveGetLabel(path.Drive "\"),   labelS := DriveGetLabel(dest.Drive "\")
		serialW := DriveGetSerial(path.Drive "\"), serialS := DriveGetSerial(dest.Drive "\")
		; MsgBox(labelW "-" myDirsMap["src"].label "`n" labelS "-" myDirsMap["dest"].label "`n" serialW "-" myDirsMap["src"].serial "`n" serialS "-" myDirsMap["dest"].serial)
		if labelW = myDirsMap["src"].label && labelS = myDirsMap["dest"].label && serialW = myDirsMap["src"].serial && serialS = myDirsMap["dest"].serial {
			result := robocopyMirror(path.path, dest.path)
			return result
		}
	}
	return false
}

WM_DEVICECHANGE(wParam, lparam, msg, hwnd) {
    static DBT_DEVICEARRIVAL := 0x8000
    ;// if new drive was inserted
    if (wParam = DBT_DEVICEARRIVAL) {
        getList := DriveGetList("FIXED")
        if InStr(getList, "W") && DriveGetLabel("W:/") = "Tom Work" {
            SetTimer(onDriveReady, -1)
            return
        }
    }
}

onDriveReady() {
    Run(ptf.lib "\Functions\syncFonts.ahk W:\_Assets\fonts")
    syncDirectories()
}



;// the below functions are ai generated
/**
 * Runs a command with no window, reading its output line by line via a pipe.
 * @param {String} cmdLine full command line
 * @param {Func} [onLine] called with each non-empty output line
 * @returns {Integer} exit code, or -1 if the process couldn't start
 */
runPiped(cmdLine, onLine := "", shouldCancel := "", onTick := "") {
    P := A_PtrSize

    sa := Buffer(P = 8 ? 24 : 12, 0)
    NumPut("UInt", sa.Size, sa, 0)
    NumPut("Int", 1, sa, P = 8 ? 16 : 8)                        ; bInheritHandle
    DllCall("CreatePipe", "Ptr*", &hRead := 0, "Ptr*", &hWrite := 0, "Ptr", sa, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hRead, "UInt", 1, "UInt", 0)

    si := Buffer(P = 8 ? 104 : 68, 0)
    NumPut("UInt", si.Size, si, 0)
    NumPut("UInt", 0x101, si, P = 8 ? 60 : 44)                  ; USESHOWWINDOW | USESTDHANDLES
    NumPut("Ptr", hWrite, si, P = 8 ? 88 : 60)                  ; hStdOutput
    NumPut("Ptr", hWrite, si, P = 8 ? 96 : 64)                  ; hStdError

    pi := Buffer(P = 8 ? 24 : 16, 0)
    ok := DllCall("CreateProcessW", "Ptr", 0, "Str", cmdLine, "Ptr", 0, "Ptr", 0
        , "Int", true, "UInt", 0x08000000                       ; CREATE_NO_WINDOW
        , "Ptr", 0, "Ptr", 0, "Ptr", si, "Ptr", pi)
    DllCall("CloseHandle", "Ptr", hWrite)
    if !ok {
        DllCall("CloseHandle", "Ptr", hRead)
        return -1
    }
    hProc := NumGet(pi, 0, "Ptr"), hThread := NumGet(pi, P, "Ptr")

    enc := "CP" DllCall("GetOEMCP")
    buf := Buffer(4096), pending := ""
    cancelled := false
    Loop {
        if onTick
            onTick()
        if shouldCancel && shouldCancel() {
            DllCall("TerminateProcess", "Ptr", hProc, "UInt", 1)
            cancelled := true
            break
        }
        DllCall("PeekNamedPipe", "Ptr", hRead, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", &avail := 0, "Ptr", 0)
        if avail {
            DllCall("ReadFile", "Ptr", hRead, "Ptr", buf, "UInt", buf.Size, "UInt*", &got := 0, "Ptr", 0)
            pending .= StrGet(buf, got, enc)
            while (pos := InStr(pending, "`n")) {
                line := Trim(SubStr(pending, 1, pos - 1), " `t`r")
                pending := SubStr(pending, pos + 1)
                if line != "" && onLine
                    onLine(line)
            }
        } else if DllCall("WaitForSingleObject", "Ptr", hProc, "UInt", 0) = 0 {
            break
        } else
            Sleep(30)
    }

    DllCall("GetExitCodeProcess", "Ptr", hProc, "UInt*", &exitCode := 0)
    for h in [hRead, hProc, hThread]
        DllCall("CloseHandle", "Ptr", h)
    return cancelled ? -2 : exitCode
}

/**
 * Mirrors src to dest with Robocopy, showing a Notify progress window.
 * @returns {Boolean} true if Robocopy exit code < 8
 */
robocopyMirror(src, dest) {
    src  := RTrim(src, "\")
    dest := RTrim(dest, "\")
    base  := Format('Robocopy "{1}" "{2}" /MIR /R:1 /NJH /NJS /NP /NDL /FP', src, dest)
    state := {cancel: false}
    n := ""
    onClick(*) {
        state.cancel := true
        try n["title"].Text := "Cancelling copy..."
    }
    pollClick() {
        if state.cancel || !IsObject(n) || !GetKeyState("LButton", "P")
            return
        MouseGetPos(,, &under)
        if under = n["hwnd"]
            onClick()
    }
    isCancelled() {
        pollClick()
        return state.cancel
    }

    ; --- pass 1: dry run, collect files to copy (safe to kill: writes nothing) ---
    n := scan := Notify.Show('Scanning... (click to cancel)',, 'C:\Windows\System32\imageres.dll|icon244', , onClick
        , 'theme=Dark dur=0 dgc=0 ts=12 tfo=norm show=Fade@250 hide=Fade@250 maxW=400')
    items := [], hasExtras := false
    collect(line) {
        if InStr(line, "EXTRA")
            return hasExtras := true
        parts := StrSplit(line, "`t")
        items.Push(Trim(parts[parts.Length]))
    }
    rc := runPiped(base ' /L', collect, isCancelled)
    Notify.Destroy(scan["hwnd"], true)

    if rc = -2
        return false
    if items.Length = 0 && !hasExtras
        return true

    ; --- pass 2: copy one file per Robocopy call, checking the flag between files ---
    total := items.Length + (hasExtras ? 1 : 0)
    n := Notify.Show('Syncing (0/' total ') - click to cancel', 'Starting...', 'C:\Windows\System32\shell32.dll|icon323', , onClick
        , 'theme=Dark dur=0 dgc=0 ts=12 tfo=norm mfo=norm show=Fade@250 hide=Fade@250 maxW=400 prog=h15 Range0-' total)

    failed := false
    for fullPath in items {
        if state.cancel
            break
        rel := SubStr(fullPath, StrLen(src) + 1)
        SplitPath(rel, &name, &relDir)
        n["msg"].Text := name
        one := Format('Robocopy "{1}" "{2}" "{3}" /R:1 /NJH /NJS /NP /NDL /NFL', src relDir, dest relDir, name)
        rc := runPiped(one,,, pollClick)
        if rc < 0 || rc >= 8
            failed := true
        n["prog"].Value := A_Index
        if !state.cancel
            n["title"].Text := 'Syncing (' A_Index '/' total ') - click to cancel'
    }

    ; --- pass 3: remove extras (instant deletions, so no need to interrupt) ---
    if !state.cancel && hasExtras {
        n["title"].Text := 'Removing extra files...'
        rc := runPiped(base)
        if rc < 0 || rc >= 8
            failed := true
        n["prog"].Value := total
    }

    Notify.Destroy(n["hwnd"], true)
    return !state.cancel && !failed
}