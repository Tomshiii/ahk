#SingleInstance Force
if WinActive("ahk_class CabinetWClass")
    {
        SendInput("{f4}" "^a" "+{BackSpace}" "cmd{Enter}") ;F4 highlights the path box, then opens cmd at the current directory
        WinWaitActive("ahk_exe cmd.exe")
        SendInput("for %i in (*.mp4) do ffmpeg -i " '"' "%i" '" ' '"' "%~ni.mp3" '"' "{Enter}") ;this requires you to have ffmpeg in your system path, otherwise this will do nothing
    }