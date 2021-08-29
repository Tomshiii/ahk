#SingleInstance Force
{
    if WinActive("ahk_class CabinetWClass")
        {
            SendInput("{f4}" "^a{Del}" "cmd{Enter}")
            WinWaitActive("ahk_exe cmd.exe")
            SendInput('for /R %f IN (*.mkv) DO ffmpeg -i "%f" -c copy "%~nf.mp4"' "{Enter}") ;this requires you to have ffmpeg in your system path, otherwise this will do nothing
            ;SendInput("!{F4}") ;if you close your window before your files are done they'll obviously not convert. The length of time needed depends on how many clips you have - easier to just close manually
        }
        ExitApp()
}