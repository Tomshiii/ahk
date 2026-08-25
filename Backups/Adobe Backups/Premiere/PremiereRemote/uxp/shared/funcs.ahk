; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
; }

__runAndWait(ahkExe, filepath, minimise := true, timeout := 3, sleepTime := 5000) {
    if !WinExist(ahkExe) {
        if !FileExist(filepath) {
            MsgBox("File doesn't exist:`n" filepath)
            return false
        }
        Run(filepath)
        if !WinWait(ahkExe,, timeout) {
            MsgBox("Waiting for file timed out:`n" filepath)
            return false
        }
        sleep sleepTime ;// needs time to boot
        if minimise {
            try WinMinimize(ahkExe)
        }
    }
    return true
}

__startUXP(title := "ahk_exe Adobe UXP Developer Tools.exe", &debugButt?) {
    WinActivate("Adobe UXP Developer Tools" A_Space title)
    premRemote := UIA.ElementFromHandle("Adobe UXP Developer Tools" A_Space title,, false)
    if !premRow := premRemote.WaitElement({Type:50025, Name:"Premiere Pro"}, 10000) {
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
    if debugButtBar.name = "Load Load & Watch" {
        debugButtBar.FindElement({Type:50000, Name:"Load"}).invoke()
    } else {
        reloadButt     := debugButtBar.FindElement({Type:50000, Name:"Reload"})
        reloadButt.click()
    }
    try debugButt  := debugButtBar.FindElement({Type:50000, Name:"Debug"})
    sleep 500
    WinMinimize("Adobe UXP Developer Tools" A_Space title)
    return true
}