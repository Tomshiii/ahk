;\\CURRENT RELEASE VERSION
global MyRelease := "v2.3.4"

#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from
SetNumLockState "AlwaysOn" ;sets numlock to always on (you can still it for macros)
SetCapsLockState "AlwaysOff" ;sets caps lock to always off (you can still it for macros)
SetScrollLockState "AlwaysOff" ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon(A_WorkingDir "\Icons\myscript.png") ;changes the icon this script uses in the taskbar
#Include "Functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script otherwise you need a full filepath
#Include "right click premiere.ahk" ;I have this here instead of running it separately because sometimes if the main script loads after this one things get funky and break because of priorities and stuff

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.11.8
;\\Current QMK Keyboard Version\\At time of last commit
;\\v2.4.9

; ============================================================================================================================================
;
; 														THIS SCRIPT IS FOR v2.0 OF AUTOHOTKEY
;				 											IT WILL NOT RUN IN v1.1
;									--------------------------------------------------------------------------------
;												Everything in this script is functional within v2.0
;											any code like "blockon()" "coords()" etc are all defined
;										in the various Functions.ahk scripts. Look there for specific code to edit
;
; ============================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; Copyright (C) <2022>  <Tom Tomshi>
;
; You are free to modify this script to your own personal uses/needs, but you must follow the terms shown in the license file in the root directory of this repo (basically just keep source code available)
; You should have received a copy of the GNU General Public License along with this script.  If not, see <https://www.gnu.org/licenses/>
;
; Please give credit to the foundation if you build on top of it, similar to how I have below, otherwise you're free to do as you wish
; Youtube playlist going through some of my AHK changes/updates (https://www.youtube.com/playlist?list=PL8txOlLUZiqXXr2PNOsNSXeCB1171lQ1b)
;
; ============================================================================================================================================

; A chunk of the code in the original versions of this script was either directly inspired by, or originally copied from Taran from LTT (https://github.com/TaranVH/) before
; I eventually modified it to work with v2.0 of ahk and made a bunch of other changes. His videos on the subject are what got me into AHK to begin with and what brought the foundation of the original
; version of this script to life.
; I use a streamdeck to run a lot of my scripts which is why a bunch of them are separated out into their own scripts in the \Streamdeck AHK\ folder.

; I use to use notepad++ to edit this script, if you want proper syntax highlighting in notepad++ for ahk go here: https://www.autohotkey.com/boards/viewtopic.php?t=50
; I now use VSCode which can be found here: https://code.visualstudio.com/
; AHK (and v2.0) syntax highlighting can be installed within the program itself.

; If you EVER get stuck in some code within any of these scripts REFRESH THE SCRIPT - by default I have it set to win + shift + r - and it will work anywhere (unless you're clicked on a program run as admin) if refreshing doesn't work open up task manager with ctrl + shift + esc and use your keyboard to find all instances of autohotkey and force close them

; =======================================================================================================================================
;
;
;				STARTUP
;
; =======================================================================================================================================
/* updateChecker()
 This function will (on first startup, NOT a refresh of the script) check which version of the script you're running, cross reference that with the main branch of the github and alert the user if there is a newer release available with a prompt to download as well as showing a changelog. This script will also perform a backup of the users current instance of the "ahk" folder this script resides in and will place it in the `\Backups` folder.
 */
updateChecker() {
	;checks if script was reloaded
	if DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)" ;this makes it so this function doesn't run on a refresh of the script, only on first startup
		return
	main:
	;release version
	;Get the current release version from github
	main := ComObject("WinHttp.WinHttpRequest.5.1")
	main.Open("GET", "https://raw.githubusercontent.com/Tomshiii/ahk/dev/My%20Scripts.ahk")
	main.Send()
	main.WaitForResponse()
	string := main.ResponseText
	foundpos := InStr(string, 'v',,,2)
	endpos := InStr(string, '"', , foundpos, 1)
	end := endpos - foundpos
	global version := SubStr(string, foundpos, end)
	toolCust("Current " A_ScriptName " Version = " MyRelease "`nCurrent Github Release = " version, "2000")
	;checking to see if the user wishes to ignore updates
	ignore := IniRead(A_WorkingDir "\Support Files\ignore.ini", "ignore", "ignore")
	if ignore = "no"
		{
			if VerCompare(MyRelease, version) < 0
				{
					;grabbing changelog info
					change := ComObject("WinHttp.WinHttpRequest.5.1")
					change.Open("GET", "https://raw.githubusercontent.com/Tomshiii/ahk/main/changelog.md")
					change.Send()
					change.WaitForResponse()
					ChangeLog := change.ResponseText
					;\\removing the warning about linking to commits
					beginwarn := InStr(ChangeLog, "###### **_",,, 1)
					endwarnfind := InStr(ChangeLog, "_**",,, 1)
					endend := endwarnfind + 5
					warnlength := endend - beginwarn
					removewarn := SubStr(ChangeLog, beginwarn, warnlength)
					warn := StrReplace(ChangeLog, removewarn, "", 1,, 1)
					;\\
					;\\deleting all [] surrounding links
					deletesquare1 := StrReplace(warn, "]", "")
					deletesquare2 := StrReplace(deletesquare1, "[", "")
					;\\
					;dealing with directories we'll need
					if not DirExist(A_Temp "\tomshi")
						DirCreate(A_Temp "\tomshi")
					if FileExist(A_Temp "\tomshi\changelog.ini")
						FileDelete(A_Temp "\tomshi\changelog.ini")
					if FileExist(A_Temp "\tomshi\changelog.txt")
						FileDelete(A_Temp "\tomshi\changelog.txt")
					;create baseline changelog
					FileAppend(deletesquare2, A_Temp "\tomshi\changelog.txt")
					;keys counts how many links are found
					keys := 0
					loop { ;this loop will go through and copy all urls to an ini file
						findurl := InStr(deletesquare2, "https://",,, A_Index)
						if findurl = 0
							break
						beginurl := findurl - 1
						findendurl := InStr(deletesquare2, ")",, findurl, 1)
						findendend := findendurl + 1
						urllength := findendend - beginurl
						removeulr := SubStr(deletesquare2, beginurl, urllength)
						valueurl := IniWrite(removeulr, A_Temp "\tomshi\changelog.ini", "urls", A_Index)
						keys += 1
					}
					loop keys { ;this loop will go through and remove all url's from the changelog
						read := FileRead(A_Temp "\tomshi\changelog.txt")
						refurl := IniRead(A_Temp "\tomshi\changelog.ini", "urls", A_Index)
						attempt := StrReplace(read, refurl, "")
						if FileExist(A_Temp "\tomshi\changelog.txt")
							FileDelete(A_Temp "\tomshi\changelog.txt")
						FileAppend(attempt, A_Temp "\tomshi\changelog.txt")
						finalchange := FileRead(A_Temp "\tomshi\changelog.txt")
					}
					if IsSet(finalchange) ;if there are no links and finalchange hasn't recieved a value, it will fall back to the original response from the changelog on github
						LatestChangeLog := finalchange
					else
						LatestChangeLog := change.ResponseText
					;we now delete those temp files
					if FileExist(A_Temp "\tomshi\changelog.ini")
						FileDelete(A_Temp "\tomshi\changelog.ini")
					if FileExist(A_Temp "\tomshi\changelog.txt")
						FileDelete(A_Temp "\tomshi\changelog.txt")
					;create gui
					MyGui := Gui("", "Scripts Release " version)
					MyGui.SetFont("S11")
					MyGui.Opt("+Resize +MinSize600x400 +MaxSize600x400")
					;set title
					Title := MyGui.Add("Text", "H40 W500", "New Scripts - Release " version)
					Title.SetFont("S15")
					;set download button
					downloadbutt := MyGui.Add("Button", "X445 Y350", "Download")
					downloadbutt.OnEvent("Click", Down)
					;set cancel button
					cancelbutt := MyGui.Add("Button", "Default X530 Y350", "Cancel")
					cancelbutt.OnEvent("Click", closegui)
					;set changelog
					ChangeLog := MyGui.Add("Edit", "X8 Y50 r18 -WantCtrlA ReadOnly w590")
					;set "don't prompt again" checkbox
					noprompt := MyGui.Add("Checkbox", "vNoPrompt X300 Y357", "Don't prompt again")
					noprompt.OnEvent("Click", prompt)
					;getting value for changelog
					ChangeLog.Value := LatestChangeLog

					MyGui.Show()
					prompt(*) {
						if noprompt.Value = 1
							IniWrite('"yes"', A_WorkingDir "\Support Files\ignore.ini", "ignore", "ignore")
						if noprompt.Value = 0
							IniWrite('"no"', A_WorkingDir "\Support Files\ignore.ini", "ignore", "ignore")
					}
					down(*) {
						MyGui.Opt("Disabled")
						yousure := MsgBox("If you have modified your scripts, overidding them with this download will result in a loss of data.`nA backup will be performed after downloading and placed in the \Backups folder but it is recommended you do one for yourself as well.`n`nPress Cancel to abort this automatic backup.", "Backup your scripts!", "1 48")
						if yousure = "Cancel"
							{
								MyGui.Opt("-Disabled")
								return
							}
						MyGui.Destroy()
						downloadLocation := FileSelect("D", , "Where do you wish to download Release " version)
						if downloadLocation = ""
							return
						else
							{
								ToolTip("Updated scripts are downloading")
								Download("https://github.com/Tomshiii/ahk/releases/download/" version "/" version ".zip", downloadLocation "\" version ".zip")
								toolCust("Release " version " of the scripts has been downloaded to " downloadLocation, "3000")
								run(downloadLocation)
								ToolTip("Your current scripts are being backed up!")
								if DirExist(A_Temp "\" MyRelease)
									DirDelete(A_Temp "\" MyRelease, 1)
								if DirExist(A_WorkingDir "\Backups\Script Backups\" MyRelease)
									{
										newbackup := MsgBox("You already have a backup of Release " MyRelease "`nDo you wish to override it and make a new backup?", "Error! Backup already exists", "4 32 4096")
										if newbackup = "Yes"
											DirDelete(A_WorkingDir "\Backups\Script Backups\" MyRelease, 1)
										else
											return
									}
								try {
									DirCopy(A_WorkingDir, A_Temp "\" MyRelease)
									DirMove(A_Temp "\" MyRelease, A_WorkingDir "\Backups\Script Backups\" MyRelease, "1")
									if DirExist(A_Temp "\" MyRelease)
										DirDelete(A_Temp "\" MyRelease, 1)
									toolCust("Your current scripts have successfully backed up to the '\Backups\Script Backups\" MyRelease "' folder", "3000")
								} catch as e {
									toolCust("There was an error trying to backup your current scripts", "2000")
									errorLog(A_ThisFunc "()", "There was an error trying to backup your current scripts", A_LineNumber)
								}
								return
							}
					}
					closegui(*) {
						MyGui.Destroy()
						return
					}
				}
			else
				return
		}
	else if ignore = "yes"
		{
			if VerCompare(MyRelease, version) < 0
				{
					toolCust("You're using an outdated version of these scripts", "1000")
					errorLog(A_ThisFunc "()", "You're using an outdated version of these scripts", A_LineNumber)
					return
				}
			else
				{
					toolCust("This script will not prompt you with a download/changelog when a new version is available", "2000")
					errorLog(A_ThisFunc "()", "This script will not prompt you when a new version is available", A_LineNumber)
					return
				}
		}
	else if ignore = "stop"
		return
	else
		{
			toolCust("You put something else in the ignore.ini file you goose", "1000")
			errorLog(A_ThisFunc "()", "You put something else in the ignore.ini file you goose", A_LineNumber)
			return
		}
}
updateChecker() ;runs the update checker

/* firstCheck()
 This function checks to see if it is the first time the user is running this script. If so, they are then given some general information regarding the script as well as a prompt to check out some useful hotkeys.
 */
firstCheck() {
	;The variable names in this function are an absolute mess. I'm not going to pretend like they make any sense AT ALL. But it works so uh yeah.
	if DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)" ;this makes it so this function doesn't run on a refresh of the script, only on first startup
		return
	if WinExist("Scripts Release " version)
		WinWaitClose("Scripts Release " version)
	if FileExist(A_Temp "\tomshi\first") ;how the function tracks whether this is the first time the user is running the script or not
		return
	else
		{
			DirCreate(A_Temp "\tomshi") ;creates the directory we'll need later
			firstCheckGUI := Gui("", "Scripts Release " MyRelease)
			firstCheckGUI.SetFont("S11")
			firstCheckGUI.Opt("-Resize AlwaysOnTop")
			;set title
			Title := firstCheckGUI.Add("Text", "H40 X8 W550", "Welcome to Tomshi's AHK Scripts : Release " MyRelease)
			Title.SetFont("S15")
			;text
			bodyText := firstCheckGUI.Add("Text", "W550 X8", "Congratulations!`nYou've gotten my main script to load without any runtime errors! (hopefully).`nYou've taken the first step to really getting the most out of these scripts!`n`nThe purpose of these scripts is to speed up both editing (mostly within the Adobe suite of programs) and random interactions with a computer. Listing off everything these scripts are capable of would take more screen real estate than you likely have and so all I can do is point you towards the comments for individual hotkeys/functions in the hopes that they explain everything for me.`nThese scripts are heavily catered to my pc/setup and as a result may run into issues on other systems (for example I have no idea how they will perform on lower end systems). Feel free to create an issue on the github for any massive problems or even consider tweaking the code to be more universal and try a pull request. I make no guarantees I will merge any PR's as these scripts are still for my own setup at the end of the day but I do actively try to make my code as flexible as possible to accommodate as many outliers as I can.")
			;buttons
			todoButton := firstCheckGUI.Add("Button", "X285 Y300", "What to Do")
			todoButton.OnEvent("Click", todoPage)
			hotkeysButton := firstCheckGUI.Add("Button", "X380 Y300", "Handy Hotkeys")
			hotkeysButton.OnEvent("Click", hotkeysPage)
			closeButton := firstCheckGUI.Add("Button", "X500 Y300", "Close")
			closeButton.OnEvent("Click", close)
			
			firstCheckGUI.OnEvent("Escape", close)
			firstCheckGUI.OnEvent("Close", close)
			close(*) {
				FileAppend("", A_Temp "\tomshi\first") ;tracks the fact the first time screen has been closed. These scripts will now not prompt the user again
				firstCheckGUI.Destroy()
			}
			todoPage(*) {
				todoGUI()	
			}
			hotkeysPage(*) {
				hotkeysGUI()
			}
			firstCheckGUI.Show("AutoSize")
		}
}
firstCheck() ;runs the firstCheck() function

/*
 This function will (on first startup, NOT a refresh of the script) delete any `\ErrorLog` files older than 30 days
 */
oldError() {
	if DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)" ;this makes it so this function doesn't run on a refresh of the script, only on first startup
		return
	loop files, A_WorkingDir "\Error Logs\*.txt"
	if DateDiff(A_LoopFileTimeCreated, A_now, "Days") < -30
		FileDelete(A_LoopFileFullPath)
}
oldError() ;runs the loop to delete old log files

/*
 This function will (on first startup, NOT a refresh of the script) delete any Adobe temp files when they're bigger than the specified amount (in GB). Adobe's "max" limits that you set within their programs is stupid and rarely chooses to work, this function acts as a sanity check. It should be noted I have created a custom location for `After Effects'` temp files to go to so that they're in the same folder as `Premiere's` just to keep things in one place. You will either have to change this folder tree to the actual default or set it to a similar place
 */
adobeTemp() {
	if DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)" ;this makes it so this function doesn't run on a refresh of the script, only on first startup
		return
	if WinExist("ahk_class tooltips_class32") ;checking to see if any tooltips are active before beginning
		WinWaitClose("ahk_class tooltips_class32")
	if WinExist("Scripts Release " MyRelease) ;checks to make sure firstCheck() isn't still running
		WinWaitClose("Scripts Release " MyRelease)
	if FileExist(A_Temp "\tomshi\adobe\" A_YDay) ;checks to see if the function has already run today
		return
	if not DirExist(A_Temp "\tomshi\adobe") ;ensures the directory we need already exists
		DirCreate(A_Temp "\tomshi\adobe")
	;SET HOW BIG YOU WANT IT TO WAIT FOR HERE (IN GB)
	largestSize := 45

	;first we set our counts to 0
	CacheSize := 0
	;then we define some filepaths, MediaCahce & PeakFiles are Adobe defaults, AEFiles has to be set within after effects' cache settings
	MediaCache := A_AppData "\Adobe\Common\Media Cache Files"
	PeakFiles := A_AppData "\Adobe\Common\Peak Files"
	AEFiles := A_AppData "\Adobe\Common\AE"
	;AGAIN ~~ for the above AE folder to exist you have to set it WITHIN THE AE CACHE SETTINGS, it IS NOT THE DEFAULT

	;now we check the listed directories and add up the size of all the files
	Loop Files, MediaCache "\*.*", "R"
		{
			cacheround := Round(CacheSize / 1073741824, 2)
			ToolTip(A_LoopFileShortName " - " cacheround "/" largestSize "GB")
			CacheSize += A_LoopFileSize
		}
	loop files, PeakFiles "\*.*", "R"
		{
			cacheround := Round(CacheSize / 1073741824, 2)
			ToolTip(A_LoopFileShortName " - " cacheround "/" largestSize "GB")
			CacheSize += A_LoopFileSize
		}
	loop files, AEFiles "\*.*", "R"
		{
			cacheround := Round(CacheSize / 1073741824, 2)
			ToolTip(A_LoopFileShortName " - " cacheround "/" largestSize "GB")
			CacheSize += A_LoopFileSize
		}
	if CacheSize > 0
		toolCust("Total Adobe cache size - " cacheround "/" largestSize "GB", "1500")
	else
		{
			toolCust("Total Adobe cache size - " CacheSize "/" largestSize "GB", "1500")
			return
		}
	;then we convert that byte total to GB
	convert := CacheSize/"1073741824"
	;now if the total is bigger than the set number, we loop those directories and delete all the files
	if convert >= largestSize
		{
			ToolTip(A_ThisFunc " is currently deleting temp files")
			try {
				loop files, MediaCache "\*.*", "R"
					FileDelete(A_LoopFileFullPath)
			}
			try {
				loop files, PeakFiles "\*.*", "R"
					FileDelete(A_LoopFileFullPath)
			}
			try {
				loop files, AEFiles "\*.*", "R"
					FileDelete(A_LoopFileFullPath)
			}
			ToolTip("")
		}
	if DirExist(A_Temp "\tomshi\adobe")
		{
			try {
				loop files, A_Temp "\tomshi\adobe\*.*"
					FileDelete(A_LoopFileFullPath)
			}
		}
	FileAppend("", A_Temp "\tomshi\adobe\" A_YDay) ;tracks the day so it will not run again today
}
adobeTemp() ;runs the loop to delete cache files
;=============================================================================================================================================
;
;		Windows
;
;=============================================================================================================================================
#HotIf ;code below here (until the next #HotIf) will work anywhere
#SuspendExempt ;this and the below "false" are required so you can turn off suspending this script with the hotkey listed below
;reloaderHotkey;
#+r:: ;this reload script will now attempt to reload all of my scripts, not only this main script
{
	DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
	SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
	if WinExist("QMK Keyboard.ahk - AutoHotkey")
		PostMessage 0x0111, 65303,,, "QMK Keyboard.ahk - AutoHotkey"
	if WinExist("Resolve_Example.ahk - AutoHotkey")
		PostMessage 0x0111, 65303,,, "Resolve_Example.ahk - AutoHotkey"
	if WinExist("textreplace.ahk - AutoHotkey")
		PostMessage 0x0111, 65303,,, "textreplace.ahk - AutoHotkey"
	;if WinExist("right click premiere.ahk - AutoHotkey")
	;	PostMessage 0x0111, 65303,,, "right click premiere.ahk - AutoHotkey"
	if WinExist("autosave.ahk - AutoHotkey")
		PostMessage 0x0111, 65303,,, "autosave.ahk - AutoHotkey"
	if WinExist("premiere_fullscreen_check.ahk - AutoHotkey")
		PostMessage 0x0111, 65303,,, "premiere_fullscreen_check.ahk - AutoHotkey"
	Reload
	Sleep 1000 ; if successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	;MsgBox "The script could not be reloaded. Would you like to open it for editing?",, 4
	Result := MsgBox("The script could not be reloaded. Would you like to open it for editing?",, 4)
		if Result = "Yes"
			{
				if WinExist("ahk_exe Code.exe")
						WinActivate
				else
					Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
			}
}

;activescriptsHotkey;
#F1:: ;This hotkey pulls up a GUI that gives information regarding all current active scripts, as well as offering the ability to close/open any of them by simply unchecking/checking the corresponding box
{
	detect() {
		DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
		SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
	}
	detect()
	MyGui := Gui("", "Tomshi Scripts Release " MyRelease)
	MyGui.SetFont("S11")
	MyGui.Opt("-Resize AlwaysOnTop")
	;nofocus
	;add an invisible button since removing the default off all the others did nothing
    removedefault := MyGui.Add("Button", "Default X0 Y0 w0 h0", "_")
	;active scripts
	text := MyGui.Add("Text", "X8 Y8 W300 H20", "Current active scripts are:")
	text.SetFont("S13")
	if A_IsSuspended = 0
		my := MyGui.Add("CheckBox", "Checked1", "My Scripts.ahk")
	else
		my := MyGui.Add("CheckBox", "Checked0", "My Scripts.ahk")
	my.ToolTip := "Clicking this checkbox will toggle suspend the script"
	my.OnEvent("Click", myClick)
	if WinExist("Alt_menu_acceleration_DISABLER.ahk - AutoHotkey")
		alt := MyGui.Add("CheckBox", "Checked1", "Alt_menu_acceleration_DISABLER.ahk")
	else
		alt := MyGui.Add("CheckBox", "Checked0", "Alt_menu_acceleration_DISABLER.ahk")
	alt.ToolTip := "Clicking this checkbox will open/close the script"
	alt.OnEvent("Click", altClick)
	if WinExist("autodismiss error.ahk - AutoHotkey")
		autodis := MyGui.Add("CheckBox", "Checked1", "autodismiss error.ahk")
	else
		autodis := MyGui.Add("CheckBox", "Checked0", "autodismiss error.ahk")
	autodis.ToolTip := "Clicking this checkbox will open/close the script"
	autodis.OnEvent("Click", autodisClick)
	if WinExist("autosave.ahk - AutoHotkey")
		autosave := MyGui.Add("CheckBox", "Checked1", "autosave.ahk")
	else
		autosave := MyGui.Add("CheckBox", "Checked0", "autosave.ahk")
	autosave.ToolTip := "Clicking this checkbox will open/close the script. Reopening it will restart the autosave timer"
	autosave.OnEvent("Click", autosaveClick)
	if WinExist("premiere_fullscreen_check.ahk - AutoHotkey")
		premFull := MyGui.Add("CheckBox", "Checked1", "premiere_fullscreen_check.ahk")
	else
		premFull := MyGui.Add("CheckBox", "Checked0", "premiere_fullscreen_check.ahk")
	premFull.ToolTip := "Clicking this checkbox will open/close the script"
	premFull.OnEvent("Click", premFullClick)
	if WinExist("QMK Keyboard.ahk - AutoHotkey")
		qmk := MyGui.Add("CheckBox", "Checked1", "QMK Keyboard.ahk")
	else
		qmk := MyGui.Add("CheckBox", "Checked0", "QMK Keyboard.ahk")
	qmk.ToolTip := "Clicking this checkbox will open/close the script"
	qmk.OnEvent("Click", qmkClick)
	if WinExist("Resolve_Example.ahk - AutoHotkey")
		resolve := MyGui.Add("CheckBox", "Checked1", "Resolve_Example.ahk")
	else
		resolve := MyGui.Add("CheckBox", "Checked0", "Resolve_Example.ahk")
	resolve.ToolTip := "Clicking this checkbox will open/close the script"
	resolve.OnEvent("Click", resolveClick)

	;images
	myImage := MyGui.Add("Picture", "w20 h-1 X275 Y33", A_WorkingDir "\Icons\myscript.png")
	altImage := MyGui.Add("Picture", "w20 h-1 X275 Y57", A_WorkingDir "\Icons\error.ico")
	autodisImage := MyGui.Add("Picture", "w20 h-1 X275 Y81", A_WorkingDir "\Icons\dismiss.ico")
	autosaveImage := MyGui.Add("Picture", "w20 h-1 X275 Y105", A_WorkingDir "\Icons\save.ico")
	premFullImage := MyGui.Add("Picture", "w20 h-1 X275 Y130", A_WorkingDir "\Icons\fullscreen.ico")
	qmkImage := MyGui.Add("Picture", "w20 h-1 X275 Y154", A_WorkingDir "\Icons\keyboard.ico")
	resolveImage := MyGui.Add("Picture", "w20 h-1 X275 Y177", A_WorkingDir "\Icons\resolve.png")

	;close button
	closeButton := MyGui.Add("Button", "X245", "Close")
	closeButton.OnEvent("Click", escape)

	;the below code allows for the tooltips on hover
	;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
	OnMessage(0x0200, On_WM_MOUSEMOVE)
	On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
	{
		static PrevHwnd := 0
		if (Hwnd != PrevHwnd)
		{
			Text := "", ToolTip() ; Turn off any previous tooltip.
			CurrControl := GuiCtrlFromHwnd(Hwnd)
			if CurrControl
			{
				if !CurrControl.HasProp("ToolTip")
					return ; No tooltip for this control.
				Text := CurrControl.ToolTip
				SetTimer () => ToolTip(Text), -1000
				SetTimer () => ToolTip(), -4000 ; Remove the tooltip.
			}
			PrevHwnd := Hwnd
		}
	}
	;below is all of the callback functions
	myClick(*){
		myVal := my.Value
		if myVal = 1
			Suspend(-1)
		else
			Suspend(-1)
	}
	qmkClick(*){
		detect()
		qmkVal := qmk.Value
		if qmkVal = 1
			Run(A_WorkingDir "\QMK Keyboard.ahk") ;this line can technically never happen but oh well
		else
			WinClose("QMK Keyboard.ahk - AutoHotkey")
	}
	resolveClick(*){
		detect()
		resolveVal := resolve.Value
		if resolveVal = 1
			Run(A_WorkingDir "\Resolve_Example.ahk") ;this line can technically never happen but oh well
		else
			WinClose("Resolve_Example.ahk - AutoHotkey")
	}
	autosaveClick(*){
		detect()
		autosaveVal := autosave.Value
		if autosaveVal = 1
			Run(A_WorkingDir "\autosave.ahk") ;this line can technically never happen but oh well
		else
			WinClose("autosave.ahk - AutoHotkey")
	}
	premFullClick(*){
		detect()
		premFullVal := premFull.Value
		if premFullVal = 1
			Run(A_WorkingDir "\premiere_fullscreen_check.ahk") ;this line can technically never happen but oh well
		else
			WinClose("premiere_fullscreen_check.ahk - AutoHotkey")
	}
	altClick(*){
		detect()
		altVal := alt.Value
		if altVal = 1
			Run(A_WorkingDir "\Alt_menu_acceleration_DISABLER.ahk") ;this line can technically never happen but oh well
		else
			WinClose("Alt_menu_acceleration_DISABLER.ahk - AutoHotkey")
	}
	autodisClick(*){
		detect()
		autodisVal := autodis.Value
		if autodisVal = 1
			Run(A_WorkingDir "\autodismiss error.ahk") ;this line can technically never happen but oh well
		else
			WinClose("autodismiss error.ahk - AutoHotkey")
	}
	
	MyGui.OnEvent("Escape", escape)
	escape(*) {
		MyGui.Destroy()
	}

	MyGui.Show("Center AutoSize")

	;add images next to checkboxes
}

;handyhotkeysHotkey;
#h::hotkeysGUI() ;this hotkey pulls up a GUI showing some useful hotkeys at your disposal while using these scripts

;suspenderHotkey;
#+`:: ;this hotkey is to suspent THIS script. This is helpful when playing games as this script will try to fire and do whacky stuff while you're playing games
{
	if A_IsSuspended = 0
		toolCust("you suspended hotkeys from the main script", "1000")
	else
		toolCust("you renabled hotkeys from the main script", "1000")
	Suspend(-1) ; toggle suspends this script.
}
#SuspendExempt false

;centreHotkey;
#c::
{
	try {
		title := WinGetTitle("A")
	} catch as e {
		toolCust("Couldn't determine the active window", "1000")
		errorLog(A_ThisHotkey, "Couldn't determine the active window", A_LineNumber)
		return
	}
	try {
		if WinGetMinMax(title) = 1 ;a return value of 1 means it is maximised
			WinRestore(title) ;winrestore will unmaximise it
	} catch as e {
		toolCust("Couldn't determine the active window", "1000")
		errorLog(A_ThisHotkey, "Couldn't determine the active window", A_LineNumber)
		return
	}
	newWidth := 1600
	newHeight := 900
	newX := A_ScreenWidth / 2 - newWidth / 2
	newY := newX / 2
	; Move any window that's not the desktop
	try{
		WinMove(newX, newY, newWidth, newHeight, title)
	}
}

;fullscreenHotkey;
#f::
{
	try {
		title := WinGetTitle("A")
	} catch as e {
		toolCust("Couldn't determine the active window", "1000")
		errorLog(A_ThisHotkey, "Couldn't determine the active window", A_LineNumber)
		return
	}
	try {
		if WinGetMinMax(title) = 0 ;a return value of 1 means it is maximised
			WinMaximize(title) ;winrestore will unmaximise it
		else
			WinRestore(title)
	} catch as e {
		toolCust("Couldn't determine the active window", "1000")
		errorLog(A_ThisHotkey, "Couldn't determine the active window", A_LineNumber)
		return
	}
}
;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		launch programs
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf not GetKeyState("F24", "P") ;important so certain things don't try and override my second keyboard
;windowspyHotkey;
Pause::switchToWindowSpy() ;run/swap to windowspy
;vscodeHotkey;
RWin::switchToVSC() ;run/swap to vscode
;streamdeckHotkey;
ScrollLock::switchToStreamdeck() ;run/swap to the streamdeck program
;taskmangerHotkey;
PrintScreen::SendInput("^+{Esc}") ;open taskmanager
;excelHotkey;
PgUp::switchToExcel() ;run/swap to excel

;These two scripts are to open highlighted text in the ahk documentation
;akhdocuHotkey;
AppsKey:: run "https://lexikos.github.io/v2/docs/AutoHotkey.htm" ;opens ahk documentation
;ahksearchHotkey;
^AppsKey:: ;opens highlighted ahk command in the documentation
{
	previous := A_Clipboard
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	ClipWait ;waits for the clipboard to contain data
	Run "https://lexikos.github.io/v2/docs/commands/" A_Clipboard ".htm"
	A_Clipboard := previous
}
;streamfoobarHotkey;
^F22:: ;opens foobar, ensures the right playlist is selected, then makes it select a song at random. This is for my stream.
{
	run "C:\Program Files (x86)\foobar2000\foobar2000.exe" ;I can't use vlc because the mii wii themes currently use that so ha ha here we goooooooo
	WinWait("ahk_exe foobar2000.exe")
	if WinExist("ahk_exe foobar2000.exe")
		WinActivate
	sleep 1000
	WinGetPos(,, &width, &height, "A")
	MouseGetPos(&x, &y)
	if ImageSearch(&xdir, &ydir, 0, 0, %&width%, %&height%, "*2 " A_WorkingDir "\ImageSearch\Foobar\pokemon.png")
		{
			MouseMove(%&xdir%, %&ydir%)
			SendInput("{Click}")
		}
	SendInput("!p" "a")
	MouseMove(%&x%, %&y%)
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf WinActive("ahk_class CabinetWClass") ;windows explorer
;explorerbackHotkey;
F21::SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer
;showmoreHotkey;
F14:: ;open the "show more options" menu in win11
{
	;Keep in mind I use dark mode on win11. Things will be different in light mode/other versions of windows
	MouseGetPos(&mx, &my)
	WinGetPos(,, &width, &height, "A")
	colour1 := 0x4D4D4D ;when hovering a folder
	colour2 := 0xFFDA70
	colour3 := 0x353535 ;when already clicked on
	colour4 := 0x777777 ;when already clicked on
	colour := PixelGetColor(%&mx%, %&my%)
	if GetKeyState("LButton", "P") ;this is here so that moveWin() can function within windows Explorer. It is only necessary because I use the same button for both scripts.
		{
			SendInput("{LButton Up}")
			WinMaximize
			return
		}
	else if ImageSearch(&x, &y, 0, 0, %&width%, %&height%, "*5 " Explorer "showmore.png")
		{
			;toolCust(colour "`n imagesearch fired", "1000") ;for debugging
			;SendInput("{Esc}")
			;SendInput("{Click}")
			if colour = colour1 || colour = colour2
				{
					;SendInput("{Click}")
					SendInput("{Esc 3}" "+{F10}")
				}
			else
				SendInput("{Esc}" "+{F10}" "+{F10}")
			return
		}
	else if (colour = colour1 || colour = colour2)
		{
			;toolCust(colour "`n colour1&2 fired", "1000") ;for debugging
			SendInput("{Click}")
			SendInput("{Esc}" "+{F10}")
			return
		}
	else if (colour = colour3 || colour = colour4)
		{
			;toolCust(colour "`n colour3&4 fired", "1000") ;for debugging
			SendInput("{Esc}" "+{F10}")
			return
		}
	else
		{
			;toolCust(colour "`n final else fired", "1000") ;for debugging
			SendInput("{Esc}" "+{F10}")
			return
		}
}

#HotIf WinActive("ahk_exe Code.exe")
;vscodemsHotkey;
!a::vscode("635") ;clicks on the `my scripts` script in vscode
;vscodefuncHotkey;
!f::vscode("600") ;clicks on my `functions` script in vscode
;vscodeqmkHotkey;
!q::vscode("685") ;clicks on my `qmk` script in vscode
;vscodechangeHotkey;
!c::vscode("550") ;clicks on my `changelog` file in vscode

#HotIf WinActive("ahk_exe firefox.exe")
;pauseyoutubeHotkey;
Media_Play_Pause:: ;pauses youtube video if there is one.
{
	coords()
	MouseGetPos(&x, &y)
	coordw()
	SetTitleMatchMode 2
	needle := "YouTube"
	try {
		title := WinGetTitle("A")
	}
	if (InStr(title, needle))
		{
			SendInput("{Space}")
			return
		}
	else loop {
		WinGetPos(,, &width,, "A")
		if ImageSearch(&xpos, &ypos, 0, 0, %&width%, "60", "*2 " firefox "youtube1.png")
			{
				MouseMove(%&xpos%, %&ypos%, 2) ;2 speed is only necessary because of my multiple monitors - if I start my mouse in a certain position, it'll get stuck on the corner of my main monitor and close the firefox tab
				SendInput("{Click}")
				coords()
				MouseMove(%&x%, %&y%, 2)
				break
			}
		else if ImageSearch(&xpos, &ypos, 0, 0, %&width%, "60", "*2 " firefox "youtube2.png")
			{
				MouseMove(%&xpos%, %&ypos%, 2) ;2 speed is only necessary because of my multiple monitors - if I start my mouse in a certain position, it'll get stuck on the corner of my main monitor and close the firefox tab
				SendInput("{Click}")
				coords()
				MouseMove(%&x%, %&y%, 2)
				break
			}
		else
			switchToOtherFirefoxWindow()
		if A_Index > 5
			{
				toolCust("Couldn't find a youtube tab", "1000")
				try {
					WinActivate(title) ;reactivates the original window
				} catch as e {
					toolCust("Failed to get information on last active window", "1000")
					errorLog(A_ThisHotkey, "Failed to get information on last active window", A_LineNumber)
				}
				SendInput("{Media_Play_Pause}") ;if it can't find a youtube window it will simply send through a regular play pause input
				return
			}
	}
	SendInput("{Space}")
}

;the below disables the numpad on youtube so you don't accidentally skip around a video
Numpad0::
Numpad1::
Numpad2::
Numpad3::
Numpad4::
Numpad5::
Numpad6::
Numpad7::
Numpad8::
Numpad9::
{
	SetTitleMatchMode 2
	needle := "YouTube"
	try {
		title := WinGetTitle("A")
	}
	if (InStr(title, needle))
		return
	else
		SendInput("{" A_ThisHotkey "}")
}
;=============================================================================================================================================
;
;		Discord
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Discord.exe") ;some scripts to speed up discord interactions
;SCO3A is the scancode for the CapsLock button. Had issues with using "CapsLock" as it would require a refresh every now and then before these discord scripts would work. Currently testing using the scancodes to see if that fixes it.
;alright scancodes didn't fix it, idk why but sometimes this function won't work until you refresh the main script. Might have to do with where I have it located in this script, maybe pulling it out into it's own script would fix it, or maybe discord is just dumb, who knows.
;scratch that, figured out what it is, in my qmk keyboard script I also had setcapslock to off and for whatever reason if that script was reloaded, my main script would break
;disceditHotkey;
SC03A & e::disc("DiscEdit.png") ;edit the message you're hovering over
;discreplyHotkey;
SC03A & r::disc("DiscReply.png") ;reply to the message you're hovering over ;this reply hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
;discreactHotkey;
SC03A & a::disc("DiscReact.png") ;add a reaction to the message you're hovering over
;discdeleteHotkey;
SC03A & d::disc("DiscDelete.png") ;delete the message you're hovering over. Also hold shift to skip the prompt
^+t::Run(A_WorkingDir "\shortcuts\DiscordTimeStamper.exe.lnk") ;opens discord timestamp program [https://github.com/TimeTravelPenguin/DiscordTimeStamper]

;=============================================================================================================================================
;
;		Photoshop
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Photoshop.exe")
;pngHotkey;
^+p::psType("png") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
;jpgHotkey;
^+j::psType("jpg") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a jpg instead of the default psd

;photopenHotkey;
XButton1::mousedragNotPrem(handTool, penTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photoselectHotkey;
Xbutton2::mousedragNotPrem(handTool, selectionTool) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;photozoomHotkey;
z::mousedragNotPrem(zoomTool, selectionTool) ;changes the tool to the zoom tool while z button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;F1::psSave()

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe AfterFX.exe")
;aetimelineHotkey;
Xbutton1::timeline("981", "550", "2542", "996") ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aeselectionHotkey;
Xbutton2::mousedragNotPrem(handAE, selectionAE) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard ini file for keyboard shortcuts
;aepreviousframeHotkey;
F21::SendInput(previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
;aenextframeHotkey;
F23::SendInput(nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
;There use to be a lot of macros about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

;premzoomoutHotkey;
SC03A & z::SendInput(zoomOut) ;\\set zoom out in the keyboard shortcuts ini ;idk why tf I need the scancode for capslock here but I blame premiere
;premselecttoolHotkey;
SC03A & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	MouseGetPos(&xpos, &ypos)
	SendInput(toolsWindow)
	SendInput(toolsWindow)
	sleep 50
	try {
        toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
		ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
    } catch as e {
        toolCust("Couldn't find the ClassNN value", "1000")
        errorLog(A_ThisHotkey, "Couldn't find the ClassNN value", A_LineNumber)
    }
	;MouseMove 34, 917 ;location of the selection tool
	if %&width% = 0 || %&height% = 0
		{
			loop {
				;for whatever reason, if you're clicked on another panel, then try to hit this hotkey, `ControlGetPos` refuses to actually get any value, I have no idea why. This loop will attempt to get that information anyway, but if it fails will fallback to the hotkey you have set within premiere
				;toolCust(A_Index "`n" %&width% "`n" %&height%, "100")
				if %&width% != 0 || %&height% != 0
					break
				if A_Index > 3
					{
						SendInput(selectionPrem)
						toolCust("Couldn't get dimensions of the class window`nUsed the selection hotkey instead", "2000")
						errorLog(A_ThisHotkey, "Couldn't get dimensions of the class window (premiere is a good program), used the selection hotkey instead", A_LineNumber)
						return
					}
				sleep 100
				SendInput(toolsWindow)
				toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
				ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
			}
		}
	if %&height% < 80 ;idk why but if the toolbar panel is less than 80 pixels tall the imagesearch fails for me????, but it only does that if using the &width/&height values of the controlgetpos. Ahk is weird sometimes
		multiply := "3"
	else
		multiply := "1"
	loop {
		if ImageSearch(&x, &y, %&toolx%, %&tooly%, %&toolx% + %&width%, %&tooly% + %&height% * multiply, "*2 " Premiere "selection.png") ;moves to the selection tool
			{
				MouseMove(%&x%, %&y%)
				break
			}
		sleep 100
		if A_Index > 3
			{
				SendInput(selectionPrem)
				toolFind("selection tool`nUsed the selection hotkey instead", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
				errorLog(A_ThisHotkey, "Couldn't find the selection tool (premiere is a good program), used the selection hotkey instead", A_LineNumber)
				return
			}
	}
	click
	MouseMove %&xpos%, %&ypos%
}
;premprojectHotkey;
RAlt & p:: ;This hotkey pulls out the project window and moves it to my second monitor since adobe refuses to just save its position in your workspace
{
	coords()
	MouseGetPos(&xpos, &ypos)
	KeyWait("Alt")
	if GetKeyState("Ctrl", "P")
		{
			KeyWait("Ctrl")
			goto added
		}
	SendInput(resetWorkspace)
	sleep 1500
	SendInput(timelineWindow) ;adjust this shortcut in the ini file
	SendInput(projectsWindow) ;adjust this shortcut in the ini file
	SendInput(projectsWindow) ;adjust this shortcut in the ini file
	sleep 300
	sanity := WinGetPos(&sanX, &sanY,,, "A") ;if you have this panel on a different monitor ahk won't be able to find it because of premiere weirdness so this value will be used in some fallback code down below
	coordw()
	try {
		loop {
			ClassNN := ControlGetClassNN(ControlGetFocus("A"))
			ControlGetPos(&toolx, &tooly, &width, &height, ClassNN)
			/* if ClassNN != "DroverLord - Window Class3"
				break */
			;the window you're searching for can end up being window class 3. Wicked. The function will now attempt to continue on without these values if it doesn't get them as it can still work due to other information we grab along the way
			if A_Index > 5
				{
					;toolCust("Function failed to find project window", "1000")
					;errorLog(A_ThisHotkey, "Function failed to find ClassNN value that wasn't the timeline", A_LineNumber)
					break
				}
		}
	} catch as e
		{
			toolCust("Function failed to find project window", "1000")
			errorLog(A_ThisHotkey, "Function failed to find ClassNN value that wasn't the timeline", A_LineNumber)
			return
		}
	;MsgBox("x " %&toolx% "`ny " %&tooly% "`nwidth " %&width% "`nheight " %&height% "`nclass " ClassNN) ;debugging
	blockOn()
	if ImageSearch(&prx, &pry, %&toolx% - "5", %&tooly% - "20", %&toolx% + "1000", %&tooly% + "100", "*2 " Premiere "project.png") ;searches for the project window to grab the track
		goto move
	else if ImageSearch(&prx, &pry, %&toolx% - "5", %&tooly% - "20", %&toolx% + "1000", %&tooly% + "100", "*2 " Premiere "project2.png") ;searches for the project window to grab the track
		goto move
	else if ImageSearch(&prx, &pry, %&toolx%, %&tooly%, %&width%, %&height%, "*2 " Premiere "project2.png") ;I honestly have no idea what the original purpose of this line was
		goto bin
	else
		{
			coords()
			if ImageSearch(&prx, &pry, %&sanX% - "5", %&sanY% - "20", %&sanX% + "1000", %&sanY% + "100", "*2 " Premiere "project.png") ;This is the fallback code if you have it on a different monitor
				goto move
			else if ImageSearch(&prx, &pry, %&sanX% - "5", %&sanY% - "20", %&sanX% + "1000", %&sanY% + "100", "*2 " Premiere "project2.png") ;This is the fallback code if you have it on a different monitor
				goto move
			else
				{
					blockOff()
					toolFind("project window", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
					errorLog(A_ThisHotkey, "Couldn't find the project window", A_LineNumber)
					return
					;if the project window is on a secondary monitor ahk can have a difficult time trying to find it. I have this issue with the monitor to the left of my "main" display
				}
		}
	move:
	MouseMove(%&prx% + "5", %&pry% +"3")
	SendInput("{Click Down}")
	coords()
	Sleep 100
	MouseMove 3592, 444, 2
	SendInput("{Click Up}")
	MouseMove(%&xpos%, %&ypos%)
	bin:
	Run("E:\_Editing stuff")
	WinWait("_Editing stuff")
	WinActivate("_Editing stuff")
	sleep 500
	coordw()
	MouseMove(0, 0)
	if ImageSearch(&foldx, &foldy, 0, 0, A_ScreenWidth, A_ScreenHeight, "*2 " Explorer "sfx.png")
		{
			MouseMove(%&foldx% + "9", %&foldy% + "5", 2)
			SendInput("{Click Down}")
			;sleep 2000
			coords()
			MouseMove(3240, 564, "2")
			SendInput("{Click Up}")
			switchToPremiere()
			WinWaitClose("Import Files")
			sleep 1000
		}
	else
		{
			blockOff
			toolFind("the sfx folder", "2000")
			errorLog(A_ThisHotkey, "Couldn't find the sfx folder in Windows Explorer", A_LineNumber)
			return
		}
	added:
	coordw()
	WinActivate("ahk_exe Adobe Premiere Pro.exe")
	if ImageSearch(&listx, &listy, 10, 3, 1038, 1072, "*2 " Premiere "list view.png")
		{
			MouseMove(%&listx%, %&listy%)
			SendInput("{Click}")
			sleep 100
		}
	if ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " Premiere "sfxinproj.png") || ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " Premiere "sfxinproj2.png")
		{
			MouseMove(%&fold2x% + "5", %&fold2y% + "2")
			SendInput("{Click 2}")
			sleep 100
		}
	else
		{
			blockOff()
			toolFind("the sfx folder in premiere", "2000")
			errorLog(A_ThisHotkey, "Couldn't find the sfx folder in Premiere Pro", A_LineNumber)
			return
		}
	loop {
		if ImageSearch(&fold3x, &fold3y, 10, 0, 1038, 1072, "*2 " Premiere "binsfx.png")
			{
				MouseMove(%&fold3x% + "20", %&fold3y% + "4", 2)
				SendInput("{Click Down}")
				MouseMove(772, 993, 2)
				sleep 250
				SendInput("{Click Up Left}")
				break
			}
		if A_Index > 5
			{
				blockOff()
				toolFind("the bin", "2000")
				errorLog(A_ThisHotkey, "Couldn't find the bin", A_LineNumber)
				return
			}
	}
	coords()
	MouseMove(%&xpos%, %&ypos%)
	blockOff()
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;prempreviouseditHotkey;
F21::wheelEditPoint(previousEditPoint) ;goes to the next edit point towards the left
;premnexteditHotkey;
F23::wheelEditPoint(nextEditPoint) ;goes to the next edit point towards the right
;playstopHotkey;
F18::SendInput(playStop) ;alternate way to play/stop the timeline with a mouse button
;nudgeupHotkey;
F14::SendInput(nudgeUp) ;setting this here instead of within premiere is required for the below hotkeys to function properly
;premslowDownHotkey;
F14 & F21::SendInput(slowDownPlayback) ;alternate way to slow down playback on the timeline with mouse buttons
;premspeedUpHotkey;
F14 & F23::SendInput(speedUpPlayback) ;alternate way to speed up playback on the timeline with mouse buttons
;premnudgedownHotkey;
Xbutton1::SendInput(nudgeDown) ;Set ctrl w to "Nudge Clip Selection Down"
;premmousedrag1Hotkey;
LAlt & Xbutton2:: ;this is necessary for the below function to work
;premmousedrag2Hotkey;
Xbutton2::mousedrag(handPrem, selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check the various Functions scripts for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

;premgooseHotkey;
F19::audioDrag("Goose_honk") ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F19 & F20
;prembleepHotkey;
F20::audioDrag("bleep")

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other - NOT an editor
;
;---------------------------------------------------------------------------------------------------------------------------------------------
GroupAdd("Editors", "ahk_exe Adobe Premiere Pro.exe")
GroupAdd("Editors", "ahk_exe AfterFX.exe")
#HotIf not WinActive("ahk_group Editors") ;code below here (until the next #HotIf) will trigger as long as premiere pro & after effects aren't active
;discordHotkey;
^+w:: ;this hotkey is to click the "discord" button in discord to access your dm's
{
	if WinExist("ahk_exe Discord.exe")
		{
			WinActivate("ahk_exe Discord.exe")
			blockOn()
			MouseGetPos(&origx, &origy)
			MouseMove(34, 52, 2)
			SendInput("{Click}")
			MouseMove(%&origx%, %&origy%, 2)
			blockOff()
		}
}
;disclocationHotkey;
^+d::switchToDisc()

;winmaxHotkey;
F14::moveWin("") ;maximise
;winleftHotkey;
XButton2::moveWin("#{Left}") ;snap left
;winrightHotkey;
XButton1::moveWin("#{Right}") ;snap right
;winminHotkey;
RButton::moveWin("") ;minimise

;alwaysontopHotkey;
^SPACE::WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top

;searchgoogleHotkey;
^+c:: ;runs a google search of highlighted text
{
	previous := A_Clipboard
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://www.google.com/search?d&q=" A_Clipboard
	A_Clipboard := previous
}

;capitaliseHotkey;
SC03A & c:: ;capitilises highlighted text
{
	previous := A_Clipboard
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	ClipWait ;waits for the clipboard to contain data
	SendInput("{BackSpace}")
	StringtoCapital := A_Clipboard
	StringtoCapital := StrUpper(StringtoCapital)
	SendInput(StringtoCapital)
	A_Clipboard := previous
}

;lowercaseHotkey;
SC03A & v:: ;lowercases highlighted text
{
	previous := A_Clipboard
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	ClipWait ;waits for the clipboard to contain data
	SendInput("{BackSpace}")
	StringtoLower := A_Clipboard
	StringtoLower := StrLower(StringtoLower)
	SendInput(StringtoLower)
	A_Clipboard := previous
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;You can check out \mouse settings.png in the root repo to check what mouse buttons I have remapped
;The below scripts are to accelerate scrolling
;wheelupHotkey;
F14 & WheelDown::SendInput("{WheelDown 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
;wheeldownHotkey;
F14 & WheelUp::SendInput("{WheelUp 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.

;The below scripts are to swap between virtual desktops
;virtualrightHotkey;
F19 & XButton2::SendInput("^#{Right}") ;you don't need these two as a sendinput, the syntax highlighting I'm using just see's ^#Right as an error and it's annoying
;virtualleftHotkey;
F19 & XButton1::SendInput("^#{Left}")

;The below scripts are to skip ahead in the youtube player with the mouse
;youskipbackHotkey;
F21::youMouse("j", "{Left}")
;youskipforHotkey;
F23::youMouse("l", "{Right}")