#SingleInstance Force
{
    if WinActive("ahk_class CabinetWClass")
        {
            SendInput("{f4}" "^a" "+{BackSpace}" "cmd{Enter}") ;F4 highlights the path box, then opens cmd at the current directory
            WinWaitActive("ahk_exe cmd.exe")
            SendInput('for /R %f IN (*.mkv) DO ffmpeg -i "%f" -codec copy -map 0:a -map 0:v "%~nf.mp4"' "{Enter}")
        }
        ExitApp()
}