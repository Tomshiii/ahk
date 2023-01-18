#SingleInstance Force
; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\tool>
; }

;this is a script to just activate the window any route documents are on then progress it forward. I have a habit of clicking off it and scrambling to move it along
if WinExist("ahk_exe obs64.exe")
    {
        if WinActive()
            {
                SendInput(KSA.screenshotOBS)
                ExitApp()
            }
        else
            {
                try {
                    title := WinGetTitle("A")
                } catch as e {
                    tool.Cust("couldn't grab active window")
                }
                WinActivate()
                sleep 50
                SendInput(KSA.screenshotOBS)
                sleep 100
                try {
                    WinActivate(title)
                } catch as e {
                    tool.Cust("couldn't activate original window")
                }
                ExitApp()
            }
    }