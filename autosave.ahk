#SingleInstance force ;only one instance of this script may run at a time!
A_MaxHotkeysPerInterval := 2000
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0

;This script will autosave your premire pro project every 5min since adobe refuses to actually do so. Thanks adobe.

/* blockOn()
 blocks all user inputs [IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (CTRL + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]
 */
blockOn()
 {
     BlockInput "SendAndMouse"
     BlockInput "MouseMove"
     BlockInput "On"
     ;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess
 }
 
/* blockOff()
  turns off the blocks on user input
  */
blockOff()
 {
     blockinput "MouseMoveOff"
     BlockInput "off"
 }

/* toolCust()
 create a tooltip with any message
 * @param message is what you want the tooltip to say
 * @param timeout is how many ms you want the tooltip to last
 */
toolCust(message, timeout)
{
	ToolTip(%&message%)
	SetTimer(timeouttime, - %&timeout%)
	timeouttime()
	{
		ToolTip("")
	}
}

save:
if WinExist("ahk_exe Adobe Premiere Pro.exe")
    {
        try {
            id := WinGetTitle("A")
        } catch as e {
            toolCust("couldn't grab active window", "1000")
        }
        blockOn()
        WinActivate("ahk_exe Adobe Premiere Pro.exe")
        sleep 1000
        SendInput("^s")
        try {
            WinActivate(id)
        } catch as e {
            toolCust("couldn't activate original window", "1000")
        }
        blockOff()
        sleep 300000
        goto save
    }
else
    {
        WinWait("ahk_exe Adobe Premiere Pro.exe")
        sleep 10000
        goto save
    }

