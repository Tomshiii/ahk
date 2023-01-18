; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Functions\runcmd>
; }

/**
 * This function is to cut repeat code across scripts. It grabs the path of the active win explorer window, runs cmd at that path and then sends whatever command you pass into it
 * @param {String} command the command you wish ahk to send into cmd
 */
convert2(command)
{
    if WinActive("ahk_class CabinetWClass")
        {
            hwnd := WinExist("A")
            expPath := WinGet.ExplorerPath(hwnd)
            runcmd(false, true, command, expPath)
            WinActivate(hwnd)
        }
}