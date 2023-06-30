; { \\ #Includes
#Include <Classes\coord>
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Classes\errorLog>
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
            switch WinGetProcessName(window) {
                case "Notepad.exe":
                    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='notepad.exe'")
                        runTarget := process.CommandLine
                case "explorer.exe":
                    hwnd := WinExist(window)
                    path := winget.ExplorerPath(hwnd)
                    if !path
                        {
                            errorLog(Error("Couldn't determine the path of the explorer window", -1),, 1)
                            return
                        }
                    runTarget := path
            }
        }
    WinGetPos(&x, &y, &width, &height, window)
    WinClose(window)
    if !WinWaitClose(window,, 1.5)
        {
            errorLog(TimeoutError("Waiting for the window to close timed out", -1, window),, 1)
            return
        }
    sleep 250
    Run(runTarget)
    if !WinWait(window,, 1.5)
        {
            try {
                sleep 100
                Run(runTarget)
                if !WinWait(window,, 1.5)
                    {
                        errorLog(TimeoutError("Waiting for the window to open timed out", -1, window),, 1)
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