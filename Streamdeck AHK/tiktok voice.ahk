#SingleInstance Force
; { \\ #Includes
#Include <Classes\ptf>
; }

;This script is designed to use the tiktok text to speech tool found : https://github.com/oscie57/tiktok-voice
;If you want a more robust option set for this script (choosing different voices) you would need to look into creating a Gui instead of just using an input box. That would be a lot more complicated to code and generally just isn't worth the effort for what I'm doing

; ////////////////////////////////////////////
;I have been unable to get this tool to work since needing a sessionid but as I don't use it I can't be bothered spending the time to fix it

;set the folder you have this tool downloaded
folder := ptf.EditingStuff "\tiktok-voice-main"
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
command := Format('py main.py -v {} -t `"{}`" -n {}.mp3 --session --'
                 , voice, tts.value, output.value
                )
RunWait(A_ComSpec " /c " command, folder)

Run(folder)