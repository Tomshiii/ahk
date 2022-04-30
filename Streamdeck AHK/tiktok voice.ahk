#SingleInstance Force
;This script is designed to use the tiktok text to speech tool found : https://github.com/oscie57/tiktok-voice
;If you're having issues with command prompt when using this script it might have something to do with where your command prompt is initially opening to. Because I launch this script from the same drive (in my case E:) as the folder where the voice tool is contained it functions as intended. But if you had this script launching from your C: drive and the tool in E: it might error out. To fix this add `SendInput("c:")` (or whatever drive letter) above `SendInput("cd " folder "{Enter}")`
;If you want a more robust option set for this script (choosing different voices) you would need to look into creating a Gui instead of just using an input box. That would be a lot more complicated to code and generally just isn't worth the effort for what I'm doing

;set the folder you have this tool downloaded
folder := "E:\_Editing stuff\tiktok-voice-main"
;set the voice type you want to use here
voice := "en_us_001"

tts := InputBox("What do you want the voice to say?", "TikTok Text to Speech", "H100")
if tts.Result = "Cancel"
    return
output := InputBox("What do you want the file to be named?", "TikTok Text to Speech", "H100")
if output.Result = "Cancel"
    return
if FileExist(folder "\" output.Value ".mp3") ;checks to see if a file has already been created
    {
        Run(folder)
        check := MsgBox("A file already exists, please remove it before continuing`nThe file can be found: " folder,, "1 256 4096")
        if check = "Cancel"
            return
    }
Run("cmd.exe")
WinWaitActive("ahk_exe cmd.exe")
SendInput("cd " folder "{Enter}")
SendInput("py main.py -v " voice " -t " '"' tts.Value '"' " -n " output.Value ".mp3" "{Enter}")
Run(folder)