/**
 * This function is to cut repeat code across scripts.
 * In windows 11 it's incredibly difficult for ahk to detect the native terminal window, because of this, this script will instead open A_ComSpec and cd to the folder the user is within.
 * @param {any} input the command you wish ahk to send into cmd
 */
convert2(input)
{
    if WinActive("ahk_class CabinetWClass")
        {
            oldClip := ClipboardAll()
            A_Clipboard := ""
            SendInput("{f4}" "^a" "^c") ;F4 highlights the path box, then opens cmd at the current directory
            if !ClipWait(2)
                {
                    tool.Cust("didn't get directory information")
                    return
                }
            dir := SplitPathObj(A_Clipboard)
            Run(A_ComSpec,,, &cmd)
            WinWaitActive(cmd,, 2)
            sleep 2000
            SendInput(dir.Drive "{Enter}")
            sleep 50
            SendInput("cd " A_Clipboard "{Enter}")
            sleep 50
            SendInput(input) ;this requires you to have ffmpeg in your system path, otherwise this will do nothing
            A_Clipboard := oldClip
        }
}