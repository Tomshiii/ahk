; { \\ #Includes
#Include <Classes\tool>
; }

/**
 * This function is to cut repeat code across scripts.
 * @param {any} input the command you wish ahk to send into cmd
 */
convert2(input)
{
    if WinActive("ahk_class CabinetWClass")
        {
            oldClip := ClipboardAll()
            A_Clipboard := ""
            SendInput("{f4}")
            sleep 200
            SendInput("^a" "^c") ;F4 highlights the path box, then opens cmd at the current directory
            if !ClipWait(2)
                {
                    tool.Cust("didn't get directory information")
                    return
                }
            Run(A_ComSpec, A_Clipboard,, &cmd)
            WinWaitActive(cmd,, 2)
            sleep 2000
            SendInput(input) ;this requires you to have ffmpeg in your system path, otherwise this will do nothing
            A_Clipboard := oldClip
        }
}