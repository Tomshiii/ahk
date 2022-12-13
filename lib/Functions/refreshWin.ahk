; { \\ #Includes
#Include <Classes\coord>
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Functions\errorLog>
; }

/**
 * A function to close a window, then reopen it in an attempt to refresh its information (for example, a txt file)
 * @param {any} window is the title of the window you wish to target
 * @param {any} runTarget is the path of the file you wish to open
 */
refreshWin(window, runTarget)
{
    coord.s()
    if window = "A"
        {
            window := WinGetTitle("A")
            if WinGetProcessName(window) = "Notepad.exe"
                {
                    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='notepad.exe'")
                        runTarget := process.CommandLine
                }
            if WinGetProcessName(window) = "explorer.exe"
                {
                    hwnd := WinExist(window)
                    path := winget.ExplorerPath(hwnd)
                    if !path
                        {
                            tool.Cust("Couldn't determine the path of the explorer window")
                            errorLog(, A_ThisFunc "()", "Couldn't determine the path of the explorer window", A_LineFile, A_LineNumber)
                            return
                        }
                    runTarget := path
                }
        }
    WinGetPos(&x, &y, &width, &height, window)
    WinClose(window)
    if !WinWaitClose(window,, 1.5)
        {
            tool.Cust("waiting for the window to close timed out")
            errorLog(, A_ThisFunc "()", "waiting for the window to close timed out", A_LineFile, A_LineNumber)
            return
        }
    sleep 250
    Run(runTarget)
    ; MsgBox(runTarget)
    if !WinWait(window,, 1.5)
        {
            try {
                sleep 100
                Run(runTarget)
                if !WinWait(window,, 1.5)
                    {
                        tool.Cust("waiting for the window to open timed out")
                        errorLog(, A_ThisFunc "()", "waiting for the window to open timed out", A_LineFile, A_LineNumber)
                        return
                    }
            }
        }
    WinActivate(window)
    prior := A_WinDelay
    A_WinDelay := 500
    WinMove(x, y, width, height, window)
    A_WinDelay := prior
}