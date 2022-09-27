global Discord := A_WorkingDir "\Support Files\ImageSearch\Discord\"
global Premiere := A_WorkingDir "\Support Files\ImageSearch\Premiere\"
global AE := A_WorkingDir "\Support Files\ImageSearch\AE\"
global Photoshop := A_WorkingDir "\Support Files\ImageSearch\Photoshop\"
global Resolve := A_WorkingDir "\Support Files\ImageSearch\Resolve\"
global VSCodeImage := A_WorkingDir "\Support Files\ImageSearch\VSCode\"
global Explorer := A_WorkingDir "\Support Files\ImageSearch\Windows\Win11\Explorer\"
global Firefox := A_WorkingDir "\Support Files\ImageSearch\Firefox\"

;define browsers
GroupAdd("Browsers", "ahk_exe firefox.exe")
GroupAdd("Browsers", "ahk_exe chrome.exe")
GroupAdd("Browsers", "ahk_exe Code.exe")

;define editors
GroupAdd("Editors", "ahk_exe Adobe Premiere Pro.exe")
GroupAdd("Editors", "ahk_exe AfterFX.exe")
GroupAdd("Editors", "ahk_exe Resolve.exe")
GroupAdd("Editors", "ahk_exe Photoshop.exe")

;\\v2.17.7
; ===========================================================================================================================================
;
;		Coordmode \\ Last updated: v2.1.6
;
; ===========================================================================================================================================
/**
 * Sets coordmode to "screen"
 */
coords() => (coordmode("pixel", "screen"), coordmode("mouse", "screen"))

/**
 * Sets coordmode to "window"
 */
coordw() => (coordmode("pixel", "window"), coordmode("mouse", "window"))

/**
 * sets coordmode to "caret"
 */
coordc() => coordmode("caret", "window")

; ===========================================================================================================================================
;
;		Tooltip \\ Last updated: v2.17.7
;
; ===========================================================================================================================================

/**
 * Create a tooltip with any message
 * @param {string} message is what you want the tooltip to say
 * @param {number} timeout is how many ms you want the tooltip to last. This value can be omitted and it will default to 1s
 * @param {0 or 1} find is whether you want this function to state "Couldn't find " at the beginning of it's tooltip. Simply add 1 for this variable if you do, or omit it if you don't
 * @param {number} xy the x & y coordinates you want the tooltip to appear. These values are unset by default and can be omitted
 * @param {number} WhichToolTip omit this parameter if you don't need multiple tooltips to appear simultaneously. Otherwise, this is a number between 1 and 20 to indicate which tooltip window to operate upon. If unspecified, that number is 1 (the first).
 */
toolCust(message, timeout := 1000, find := "", x?, y?, WhichToolTip?)
{
	if find != 1
		messageFind := ""
	else
		messageFind := "Couldn't find "
    ToolTip(messageFind message, x?, y?, WhichToolTip?)
    SetTimer(timeouttime, - timeout)
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
/**
 * blocks all user inputs [IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (CTRL + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]
 */
blockOn() => (BlockInput("SendAndMouse"), BlockInput("MouseMove"), BlockInput("On")) ;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess

/**
 * turns off the blocks on user input
 */
blockOff() => (Blockinput("MouseMoveOff"), BlockInput("off"))

; ===========================================================================================================================================
;
;		Mouse Drag \\ Last updated: v2.12.3
;
; ===========================================================================================================================================
/**
 * press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
 * @param tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
 * @param toolorig is the button you want the script to press to bring you back to your tool of choice
*/
mousedragNotPrem(tool, toolorig)
{
    click("middle") ;middle clicking helps bring focus to the timeline/workspace you're in, just incase
    SendInput tool "{LButton Down}"
    KeyWait(A_ThisHotkey)
    SendInput("{LButton Up}")
    SendInput toolorig
}

; ===========================================================================================================================================
;
;		better timeline movement \\ Last updated: v2.3.11
;
; ===========================================================================================================================================
/**
 * A weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
 * @param timeline in this function defines the y pixel value of the top bar in your video editor that allows you to click it to drag along the timeline
 * @param x1 is the furthest left pixel value of the timeline that will work with your cursor warping up to grab it
 * @param x2 is the furthest right pixel value of the timeline that will work with your cursor warping up to grab it
 * @param y1 is just below the bar that your mouse will be warping to, this way your mouse doesn't try doing things when you're doing other stuff above the timeline
 */
timeline(timeline, x1, x2, y1)
{
    coordw()
    MouseGetPos(&xpos, &ypos)
    if(xpos > x1 and xpos < x2) and (ypos > y1) ;this function will only trigger if your cursor is within the timeline. This ofcourse can break if you accidently move around your workspace
        {
            blockOn()
            MouseMove(xpos, timeline) ;this will warp the mouse to the top part of your timeline defined by &timeline
            SendInput("{Click Down}")
            MouseMove(xpos, ypos)
            blockOff()
            KeyWait(A_ThisHotkey)
            SendInput("{Click Up}")
        }
    else
        return
}


; ===========================================================================================================================================
;
;		Error Log \\ Last updated: v2.17.2
;
; ===========================================================================================================================================
/**
 * A function designed to log errors in scripts if they occur
 * @param func just type `A_ThisFunc "()"` if it's a function or `A_ThisHotkey "::"` if it's a hotkey
 * @param error is what text you want logged to explain the error
 * @param lineFile just type `A_LineFile`
 * @param lineNumber just type `A_LineNumber`
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
                InstalledVersion := IniRead(A_MyDocuments "\tomshi\settings.ini", "Track", "version")
                LatestReleaseBeta := getScriptRelease(True)
                LatestReleaseMain := getScriptRelease()
                if LatestReleaseBeta = LatestReleaseMain
                    LatestReleaseBeta := ""
                time := A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec "." A_MSec
                start := "\\ ErrorLogs`n\\ AutoHotkey v" A_AhkVersion "`n\\ Tomshi's Scripts" "`n`t\\ Installed Version - " InstalledVersion "`n`t\\ Latest Version Released`n`t`t\\ main - " LatestReleaseMain "`n`t`t\\ beta - " LatestReleaseBeta "`n\\ OS`n`t\\ " OSName "`n`t\\ " A_OSVersion "`n`t\\ " OSArch "`n\\ CPU`n`t\\ " CPU "`n`t\\ Logical Processors - " Logical "`n\\ RAM`n`t\\ Total Physical Memory - " Memory "GB`n`t\\ Free Physical Memory - " FreePhysMem "GB`n\\ Current DateTime - " time "`n\\ Ahk Install Path - " A_AhkPath "`n`n"
            }
        }
    scriptPath :=  lineFile ;this is taking the path given from A_LineFile
    scriptName := SplitPath(scriptPath, &name) ;and splitting it out into just the .ahk filename
    FileAppend(start A_Hour ":" A_Min ":" A_Sec "." A_MSec " // ``" func "`` encountered the following error: " '"' error '"' " // Script: ``" name "``, Line Number: " lineNumber "`n", A_WorkingDir "\Error Logs\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
}

; ===========================================================================================================================================
;
;		Other \\ Last updated: v2.17.3
;
; ===========================================================================================================================================
/**
 * This function will return the name of the first & second hotkeys pressed when two are required for a macro to fire. If the hotkey used with this function is only 2 characters long, it will assign each of those to &first & &second respectively. If one of those characters is a special key (ie. ! or ^) it will return the virtual key so `KeyWait` will still work as expected
 * @param first is the variable that will be filled with the first activation hotkey. Must be written as `&var`
 * @param second is the variable that will be filled with the second activation hotkey. Must be written as `&var`
*/
getHotkeys(&first, &second)
{
   getHotkey := A_ThisHotkey
   length := StrLen(getHotkey)
   if length = 2
	{
		first := SubStr(getHotkey, 1, 1)
		second := SubStr(getHotkey, 2, 1)
		vk(variable)
		{
			if variable = "#" || variable = "!" || variable = "^" || variable = "+" || variable = "<^>!"
				{
					if variable = "#"
						variable := "Win"
					if variable = "!"
						variable := "Alt"
					if variable = "^"
						variable := "Ctrl"
					if variable = "+"
						variable := "Shift"
					if variable = "<^>!"
						variable := "AltGr"
					check := GetKeyVK(variable)
					vkReturn := Format("vk{:X}", check)
					return vkReturn
				}
			else
				return
		}
		check1 := vk(first)
		check2 := vk(second)
		if check1 != ""
			first := check1
		if check2 != ""
			second := check2
		return
	}
   andValue := InStr(getHotkey, "&",, 1, 1)
   first := SubStr(getHotkey, 1, length - (length - andValue) - 2)
   second := SubStr(getHotkey, andValue + 2, length - andValue + 2)
   return
}

/**
 * `Floor()` is a built in math function of ahk to round down to the nearest integer, but when you want a decimal place to round down, you don't really have that many options. This function will allow us to round down after a certain amount of decimal places
 */
floorDecimal(num,dec) => RegExReplace(num,"(?<=\.\d{" dec "}).*$")

/**
 * A function to loop through and hard reset all active ahk scripts
 */
hardReset()
{
    DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
    SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.

    toolCust("All active ahk scripts are being rerun")
    value := WinGetList("ahk_class AutoHotkey")
    for this_value in value
        {
            name := WinGettitle(this_value)
            path := SubStr(name, 1, InStr(name, " -",,, 1) -1)
            SplitPath(path, &ScriptName)
            if ScriptName = "checklist.ahk" || ScriptName = "My Scripts.ahk" || ScriptName = "launcher.ahk"
                continue
            Run(path)
        }
    if WinExist("ahk_class tooltips_class32") ;checking to see if any tooltips are active before beginning
        WinWaitClose("ahk_class tooltips_class32",, 1)
    Run(A_ScriptFullPath) ;run this current script last so all of the rest actually happen
}