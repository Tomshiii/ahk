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
    if !WinWait(fullTitle,, 5) {
        MsgBox("Failed to find the UXP plugin window",, "T3")
        return false
    }
    WinActivate(fullTitle)
    WinWaitActive(fullTitle,, 2)
    sleep 150
    premRemote := UIA.ElementFromHandle(fullTitle,, true)
    if !premRow := premRemote.WaitElement({Type:50025, Name:"Premiere"}, 10000) {
        MsgBox("Failed to find the UXP plugin window",, "T3")
        return false
    }
    children := premRow.Children

    index := 0
    offset := 3
    for i, child in children {
        if child.Name == "de.sebinside.premiereremote" {
            index := i
            break
        }
    }
    if index = 0 {
        notifyExt.showIfNotExist('uxpRebuildFailedChild',, "Failed to find de.sebinside.premiereremote child")
        return false
    }
    debugButtBar  := children[index+offset]
    if debugButtBar.name = "Load Load & Watch" || debugButtBar.name = "Debug Reload Watch Unload" {
        set := false
        for children in debugButtBar.Children {
            if children.Name != "" {
                set := true
                break
            }
        }
        try debugButtBar.FindElement({Type:50000, Name:"Load"}).invoke()
        catch {
            try {
                reloadButt := debugButtBar.FindElement({Type:50000, Name:"Reload"})
                reloadButt.click()
            } catch {
                try debugButtBar.FindElement({Type:50000, Name:"Unload"}).invoke()
                try debugButtBar.WaitElement({Type:50000, Name:"Load"}, 2000).invoke()
            }
        }
    } else {
        if children[index+1].name = "Not loaded" {
            try debugButtBar.FindElement({Type:50000, Name:"Load"}).invoke()
            sleep 250
        }
        try {
            reloadButt := debugButtBar.FindElement({Type:50000, Name:"Reload"})
            reloadButt.click()
        }
    }
    try debugButt  := debugButtBar.FindElement({Type:50000, Name:"Debug"})
    sleep 500
    WinMinimize("Adobe UXP Developer Tools" A_Space title)
    return true
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