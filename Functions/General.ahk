global Discord := A_WorkingDir "\Support Files\ImageSearch\Discord\"
global Premiere := A_WorkingDir "\Support Files\ImageSearch\Premiere\"
global AE := A_WorkingDir "\Support Files\ImageSearch\AE\"
global Photoshop := A_WorkingDir "\Support Files\ImageSearch\Photoshop\"
global Resolve := A_WorkingDir "\Support Files\ImageSearch\Resolve\"
global VSCodeImage := A_WorkingDir "\Support Files\ImageSearch\VSCode\"
global Explorer := A_WorkingDir "\Support Files\ImageSearch\Windows\Win11\Explorer\"
global Firefox := A_WorkingDir "\Support Files\ImageSearch\Firefox\"

;\\v2.12.1

; ===========================================================================================================================================
;
;		Coordmode \\ Last updated: v2.1.6
;
; ===========================================================================================================================================
/* coords()
 sets coordmode to "screen"
 */
coords()
{
    coordmode "pixel", "screen"
    coordmode "mouse", "screen"
}
 
/* coordw()
  sets coordmode to "window"
  */
coordw()
{
    coordmode "pixel", "window"
    coordmode "mouse", "window"
}
 
/* coordc()
  * sets coordmode to "caret"
  */
coordc()
{
    coordmode "caret", "window"
}
 
; ===========================================================================================================================================
;
;		Tooltip \\ Last updated: v2.10.5
;
; ===========================================================================================================================================
 
/* toolFind()
  create a tooltip for errors trying when to find things
  * @param message is what you want the tooltip to say after "couldn't find"
  * @param timeout is how many ms you want the tooltip to last
  */
toolFind(message, timeout)
{
    ToolTip("Couldn't find " %&message%)
    SetTimer(timeouttime, - %&timeout%)
    timeouttime()
    {
        ToolTip("")
    }
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
 
; ===========================================================================================================================================
;
;		Blockinput \\ Last updated: v2.0.1
;
; ===========================================================================================================================================
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
 
; ===========================================================================================================================================
;
;		Mouse Drag \\ Last updated: v2.12.1
;
; ===========================================================================================================================================
/* mousedrag()
  press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example). This version is specifically for Premiere Pro, the below function is for any other program
  @param tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
  @param toolorig is the button you want the script to press to bring you back to your tool of choice
  */
mousedrag(tool, toolorig)
{
    if GetKeyState("RButton", "P") ;this check is to allow some code in `right click premiere.ahk` to work
        return
    MouseGetPos(&x, &y) ;from here down to the begining of again() is checking for the width of your timeline and then ensuring this function doesn't fire if your mouse position is beyond that, this is to stop the function from firing while you're hoving over other elements of premiere causing you to drag them across your screen
    static xValue := 0
    if xValue = 0
        {
            if ImageSearch(&scrollX, &scrollY, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Premiere "scroll.png")
                {
                    static xValue := %&scrollX%
                    toolCust(A_ThisFunc "() found the scroll at the end of the timeline.`nx position := " %&scrollX%, "750")
                }
            else
                {
                    toolCust(A_ThisFunc "() couldn't determine the scroll position", "2000")
                    errorLog(A_ThisFunc "()", "Couldn't determine the scroll position", A_LineFile, A_LineNumber)
                    goto skip ;to avoid getting stuck if the function can't find the scroll
                }
            ;MsgBox(%&scrollX%) ;testing
        }
    if %&x% > xValue || %&x% < 200 ;the function will not fire beyond the end of the timeline and before about 200 on the x value. Since the left side of the timeline is about 250px~ wide, this part of the function assumes you have your timeline beggining on the left side of your screen 
        return
    skip:
    again()
    {
        if A_ThisHotkey = DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
            {
                if not GetKeyState(A_ThisHotkey, "P") ;this is here so it doesn't reactivate if you quickly let go before the timer comes back around
                    return
            }
        else if not GetKeyState(DragKeywait, "P")
            return
        click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
        SendInput %&tool% "{LButton Down}"
        if A_ThisHotkey = DragKeywait ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
            KeyWait(A_ThisHotkey)
        else
            KeyWait(DragKeywait) ;A_ThisHotkey won't work here as the assumption is that LAlt & Xbutton2 will be pressed and ahk hates that
        SendInput("{LButton Up}")
        SendInput %&toolorig%
    }
    SetTimer(again, -400)
    again()
}

/* mousedragNotPrem()
  press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
  @param tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
  @param toolorig is the button you want the script to press to bring you back to your tool of choice
*/
mousedragNotPrem(tool, toolorig)
{
    click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
    SendInput %&tool% "{LButton Down}"
    KeyWait(A_ThisHotkey)
    SendInput("{LButton Up}")
    SendInput %&toolorig%
}
 
; ===========================================================================================================================================
;
;		better timeline movement \\ Last updated: v2.3.11
;
; ===========================================================================================================================================
/* timeline()
  a weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
  @param timeline in this function defines the y pixel value of the top bar in your video editor that allows you to click it to drag along the timeline
  @param x1 is the furthest left pixel value of the timeline that will work with your cursor warping up to grab it
  @param x2 is the furthest right pixel value of the timeline that will work with your cursor warping up to grab it
  @param y1 is just below the bar that your mouse will be warping to, this way your mouse doesn't try doing things when you're doing other stuff above the timeline
  */
timeline(timeline, x1, x2, y1)
{
    coordw()
    MouseGetPos(&xpos, &ypos)
    if(%&xpos% > %&x1% and %&xpos% < %&x2%) and (%&ypos% > %&y1%) ;this function will only trigger if your cursor is within the timeline. This ofcourse can break if you accidently move around your workspace
        {
            blockOn()
            MouseMove(%&xpos%, %&timeline%) ;this will warp the mouse to the top part of your timeline defined by &timeline
            SendInput("{Click Down}")
            MouseMove(%&xpos%, %&ypos%)
            blockOff()
            KeyWait(A_ThisHotkey)
            SendInput("{Click Up}")
        }
    else
        return
}
 
 
; ===========================================================================================================================================
;
;		Error Log \\ Last updated: v2.11
;
; ===========================================================================================================================================
/* errorLog()
  A function designed to log errors in scripts if they occur
  @param func just type `A_ThisFunc "()"` if it's a function or `A_ThisHotkey` if it's a hotkey
  @param error is what text you want logged to explain the error
  @param lineFile just type `A_LineFile`
  @param lineNumber just type `A_LineNumber`
  */
errorLog(func, error, lineFile, lineNumber)
{
    start := ""
    text := ""
    if not DirExist(A_WorkingDir "\Error Logs")
        DirCreate(A_WorkingDir "\Error Logs")
    if not FileExist(A_WorkingDir "\Error Logs\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
        {
            try {
                ;These values can be found at the following link (and the other appropriate tabs) - https://docs.microsoft.com/en-gb/windows/win32/cimwin32prov/win32-process
                For Process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")
                    OSNameResult := Process.OSName
                removePathPos := InStr(OSNameResult, "|",,, 1)
                if removePathPos != 0
                    OSName := SubStr(OSNameResult, 1, removePathPos - 1)
                else
                    OSName := OSNameResult
                For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
                    OSArch := OperatingSystem.OSArchitecture
                For Processor in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Processor")
                    CPU := Processor.Name
                For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem")
                    Logical := ComputerSystem.NumberOfLogicalProcessors
                For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem")
                    Response := ComputerSystem.TotalPhysicalMemory / "1073741824"
                For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
                    Response2 := OperatingSystem.FreePhysicalMemory / "1048576"
                Memory := Round(Response, 2)
                FreePhysMem := Round(Response2, 2)
                time := A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec "." A_MSec
                start := "\\ ErrorLogs`n\\ AutoHotkey v" A_AhkVersion "`n\\ OS`n" A_Tab "\\ " OSName "`n" A_Tab "\\ " A_OSVersion "`n" A_Tab "\\ " OSArch "`n\\ CPU`n" A_Tab "\\ " CPU "`n" A_Tab "\\ Logical Processors - " Logical "`n\\ RAM`n" A_Tab "\\ Total Physical Memory - " Memory "GB`n" A_Tab "\\ Free Physical Memory - " FreePhysMem "GB`n\\ Current DateTime - " time "`n\\ Ahk Install Path - " A_AhkPath "`n`n"
            }
        }
    scriptPath :=  %&lineFile% ;this is taking the path given from A_LineFile
    scriptName := SplitPath(scriptPath, &name) ;and splitting it out into just the .ahk filename
    FileAppend(start A_Hour ":" A_Min ":" A_Sec "." A_MSec " // ``" %&func% "`` encountered the following error: " '"' %&error% '"' " // Script: ``" %&name% "``, Line Number: " %&lineNumber% "`n", A_WorkingDir "\Error Logs\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
}