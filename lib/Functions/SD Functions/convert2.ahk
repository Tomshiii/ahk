; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Classes\cmd>
; }

/**
 * This function is to cut repeat code across scripts. It grabs the path of the active win explorer window, runs cmd at that path and then sends whatever command you pass into it.
 *
 * *This function may recurse further into folders searching for files to convert.*
 * @param {String} command the command you wish ahk to send into cmd
 */
convert2(command)
{
    if WinActive("ahk_class CabinetWClass")
        {
            hwnd := WinExist("A")
            expPath := WinGet.ExplorerPath(hwnd)
            cmd.run(false, true, command, expPath)
            try {
                WinActivate(hwnd)
            }
        }
}