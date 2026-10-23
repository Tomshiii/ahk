; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
; }

__runAndWait(ahkExe, filepath, minimise := true, timeout := 3, sleepTime := 5000) {
    orig := detect()
    if !WinExist(ahkExe) {
        if !FileExist(filepath) {
            resetOrigDetect(orig)
            MsgBox("File doesn't exist:`n" filepath)
            return false
        }
        Run(filepath)
        if !WinWait(ahkExe,, timeout) {
            resetOrigDetect(orig)
            MsgBox("Waiting for file timed out:`n" filepath)
            return false
        }
        sleep sleepTime ;// needs time to boot
        if minimise {
            try WinMinimize(ahkExe)
        }
    }
    resetOrigDetect(orig)
    return true
}

__startUXP(title := "ahk_exe Adobe UXP Developer Tools.exe") {
    fullTitle := "Adobe UXP Developer Tools" A_Space title
    if !__uxpFocus(fullTitle)
        return false

    ; read the row; if State and the action buttons disagree, escalate:
    ; 1) click Unload to reset the row, 2) kill and relaunch UDT, 3) give up
    loop 3 {
        info := __uxpReadRow(fullTitle)
        if !info
            return false
        state   := info.state
        buttBar := info.bar
        hasLoad   := __uxpHas(buttBar, "Load")
        hasReload := __uxpHas(buttBar, "Reload")

        consistent := (state = "Not loaded") ? (hasLoad && !hasReload) : hasReload
        if consistent
            break

        if A_Index = 1 {
            try buttBar.FindElement({Type:50000, Name:"Unload"}).invoke()
            ; wait for the bar to flip to the unloaded layout instead of sleeping
            try buttBar.WaitElement({Type:50000, Name:"Load"}, 2000)
        } else if A_Index = 2 {
            if !__uxpRestart(fullTitle)
                return false
        } else {
            notifyExt.showIfNotExist('uxpStaleState',, "UXP UI state still inconsistent after restart")
            return false
        }
    }

    if state = "Not loaded" {
        try buttBar.FindElement({Type:50000, Name:"Load"}).invoke()
        catch {
            return false
        }
    } else {
        try buttBar.FindElement({Type:50000, Name:"Reload"}).click()
        catch {
            try buttBar.FindElement({Type:50000, Name:"Unload"}).invoke()
            try buttBar.WaitElement({Type:50000, Name:"Load"}, 2000).invoke()
        }
    }

    sleep 500
    WinMinimize(fullTitle)
    return true
}

; kill UDT and launch it again; readiness is handled by __uxpReadRow's UIA wait
__uxpRestart(fullTitle, exePath := "C:\Program Files\Adobe\Adobe UXP Developer Tools\Adobe UXP Developer Tools.exe") {
    exeName := "Adobe UXP Developer Tools.exe"
    try ProcessClose(exeName)
    ProcessWaitClose(exeName, 3)
    if !FileExist(exePath) {
        MsgBox("UXP exe doesn't exist:`n" exePath)
        return false
    }
    Run(exePath)
    if !WinWait(fullTitle,, 10) {
        MsgBox("UXP window didn't reappear",, "T3")
        return false
    }
    return __uxpFocus(fullTitle)
}

; polls until the Premiere row is fully populated, returns {state, bar} or false
__uxpReadRow(fullTitle, timeout := 15000) {
    start := A_TickCount
    while A_TickCount - start < timeout {
        try {
            root    := UIA.ElementFromHandle(fullTitle,, false)
            premRow := root.FindElement({Type:50025, Name:"Premiere"})
            if premRow {
                children := premRow.Children
                for i, child in children {
                    if child.Name == "de.sebinside.premiereremote" {
                        if children.Length >= i+3 {
                            bar := children[i+3]
                            ; the bar must have at least one named button, i.e. it has rendered
                            for btn in bar.Children {
                                if btn.Name != ""
                                    return {state: children[i+1].Name, bar: bar}
                            }
                        }
                        break
                    }
                }
            }
        }
        sleep 100
    }
    notifyExt.showIfNotExist('uxpRebuildFailedChild',, "Failed to find a populated de.sebinside.premiereremote row")
    return false
}

; wait for the window, restore it if minimised, and focus it
__uxpFocus(fullTitle) {
    if !WinWait(fullTitle,, 5) {
        MsgBox("Failed to find the UXP plugin window",, "T3")
        return false
    }
    if WinGetMinMax(fullTitle) = -1
        WinRestore(fullTitle)
    WinActivate(fullTitle)
    WinWaitActive(fullTitle,, 2)
    sleep 150
    return true
}
__uxpHas(bar, name) {
    try {
        bar.FindElement({Type:50000, Name:name})
        return true
    }
    return false
}

__replaceCompose(composeFile := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\compose.yaml") {
    content := FileRead(composeFile)

    if !InStr(content, "restart: unless-stopped") {
        indent := Chr(32) Chr(32) Chr(32) Chr(32)  ; 4 spaces, built from char codes, cannot be tab-corrupted
        newLine := Chr(10)                          ; explicit LF
        content := RTrim(content, " `t`r`n")
        content := content . newLine . indent . "restart: unless-stopped" . newLine

        f := FileOpen(composeFile, "w")
        f.Write(content)
        f.Close()
    }
}