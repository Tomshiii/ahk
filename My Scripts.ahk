#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from
SetNumLockState "AlwaysOn" ;sets numlock to always on (you can still it for macros)
SetCapsLockState "AlwaysOff" ;sets caps lock to always off (you can still it for macros)
SetScrollLockState "AlwaysOff" ;sets scroll lock to always off (you can still it for macros)
SetDefaultMouseSpeed 0 ;sets default MouseMove speed to 0 (instant)
SetWinDelay 0 ;sets default WinMove speed to 0 (instant)
TraySetIcon("C:\Program Files\ahk\ahk\Icons\myscript.png") ;changes the icon this script uses in the taskbar
#Include "MS_functions.ahk" ;includes function definitions so they don't clog up this script. MS_Functions must be in the same directory as this script otherwise you need a full filepath
#Include "right click premiere.ahk" ;I have this here instead of running it separately because sometimes if the main script loads after this one thing get funky and break because of priorities and stuff

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.8.8
;\\Minimum Version of "MS_Functions.ahk" Required for this script
;\\v2.9
;\\Current QMK Keyboard Version\\At time of last commit
;\\v2.4.2

;\\CURRENT RELEASE VERSION
global MyRelease := "v2.3"

; ============================================================================================================================================
;
; 														THIS SCRIPT IS FOR v2.0 OF AUTOHOTKEY
;				 											IT WILL NOT RUN IN v1.1
;									--------------------------------------------------------------------------------
;												Everything in this script is functional within v2.0
;											any code like "blockon()" "coords()" etc are all defined
;										in the MS_functions.ahk script. Look there for specific code to edit
;
; ============================================================================================================================================
;
; This script was created by & for Tomshi (https://www.youtube.com/c/tomshiii, https://www.twitch.tv/tomshi)
; Its purpose is to help speed up editing and random interactions with windows.
; Copyright (C) <2022>  <Tom Tomshi>
;
; You are free to modify this script to your own personal uses/needs, but you must follow the terms shown in the license file in the root directory of this repo (basically just keep source code available)
; You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>
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
;
; =======================================================================================================================================
;\\The below code will check what version you're running on startup
updateChecker() {
	;checks if script was reloaded
	if DllCall("GetCommandLine", "str") ~= "i) /r(estart)?(?!\S)"
		return
	;release version
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", "https://raw.githubusercontent.com/Tomshiii/ahk/dev/Support%20Files/Release.txt")
	whr.Send()
	whr.WaitForResponse()
	global version := whr.ResponseText
	if version = MyRelease
		return
	else
		{
			url := '"https://github.com/tomshiii/ahk/releases/latest"'
			ignore := IniRead(A_WorkingDir "\Support Files\ignore.ini", "ignore", "ignore")
			if ignore = "no"
				{
					;grabbing changelog info
					change := ComObject("WinHttp.WinHttpRequest.5.1")
					change.Open("GET", "https://raw.githubusercontent.com/Tomshiii/ahk/dev/Support%20Files/changelog.txt")
					change.Send()
					change.WaitForResponse()
					LatestChangeLog := change.ResponseText

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
						MyGui.Destroy()
						downloadLocation := DirSelect("::{20d04fe0-3aea-1069-a2d8-08002b30309d}", "3", "Where do you wish to download Release " version)
						if downloadLocation = ""
							return
						else
							{
								Download("https://github.com/Tomshiii/ahk/releases/download/" version "/" version ".zip", downloadLocation "\" version ".zip")
								toolCust("Release " version " of the scripts has been downloaded to " downloadLocation, "1000")
								run(downloadLocation)
								return
							}
					}
					closegui(*) {
						MyGui.Destroy()
						return
					}
				}
			else if ignore = "yes"
				toolCust("You're using an outdated version of these scripts", "1000")
			else if ignore = "stop"
				return
			else
				toolCust("You put something else in the ignore.ini file you goose", "1000")
		}
}
updateChecker() ;runs the update checker
;\\end of update checker

;=============================================================================================================================================
;
;		Windows
;
;=============================================================================================================================================
#HotIf ;code below here (until the next #HotIf) will work anywhere
#SuspendExempt ;this and the below "false" are required so you can turn off suspending this script with the hotkey listed below
#+r:: ;this reload script will now attempt to reload all of my scripts, not only this main script
{
	DetectHiddenWindows True  ; Allows a script's hidden main window to be detected.
	SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
	if WinExist("QMK Keyboard.ahk")
		PostMessage 0x0111, 65303,,, "QMK Keyboard.ahk - AutoHotkey"
	if WinExist("Resolve_Example.ahk")
		PostMessage 0x0111, 65303,,, "Resolve_Example.ahk - AutoHotkey"
	if WinExist("textreplace.ahk")
		PostMessage 0x0111, 65303,,, "textreplace.ahk - AutoHotkey"
	;if WinExist("right click premiere.ahk")
	;	PostMessage 0x0111, 65303,,, "right click premiere.ahk - AutoHotkey"
	if WinExist("ahk_exe Adobe Premiere Pro.exe")
		PostMessage 0x0111, 65303,,, "autosave.ahk - AutoHotkey"
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

#+`::
{
	if A_IsSuspended = 0
		toolCust("you suspended hotkeys from the main script", "1000")
	else
		toolCust("you renabled hotkeys from the main script", "1000")
	Suspend(-1) ;suspends this script. Useful when playing games as this script will try and do whacky stuff while gaming
}
#SuspendExempt false
;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		launch programs
;
;---------------------------------------------------------------------------------------------------------------------------------------------
#HotIf not GetKeyState("F24", "P") ;important so certain things don't try and override my second keyboard
PgUp::switchToExcel() ;run microsoft excel.
Pause::switchToWindowSpy() ;run windowspy
RWin::switchToVSC() ;run vscode
ScrollLock::switchToStreamdeck() ;run the streamdeck program
PrintScreen::SendInput("^+{Esc}")
PgDn::switchToWord()

;These two scripts are to open highlighted text in the ahk documentation
AppsKey:: run "https://lexikos.github.io/v2/docs/AutoHotkey.htm" ;opens ahk documentation
^AppsKey:: ;opens highlighted ahk command in the documentation
{
	A_Clipboard := "" ;clears the clipboard
	Send("^c")
	ClipWait ;waits for the clipboard to contain data
	Run "https://lexikos.github.io/v2/docs/commands/" A_Clipboard ".htm"
}
F22:: ;opens foobar, ensures the right playlist is selected, then makes it select a song at random
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
WheelLeft::SendInput("!{Up}") ;Moves back 1 folder in the tree in explorer
F14:: ;open the "show more options" menu in win11
{
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
!a::vscode("myScripts") ;clicks on the my scripts script in vscode
!f::vscode("msFunc") ;clicks on my msfunctions script in vscode 
!q::vscode("qmk") ;clicks on my qmk script in vscode
!c::vscode("change") ;clicks on my changelog file in vscode

#HotIf WinActive("ahk_exe firefox.exe")
Media_Play_Pause:: ;pauses youtube video if there is one.
{
	coords()
	MouseGetPos(&x, &y)
	coordw()
	SetTitleMatchMode 2
	needle := "YouTube"
	title := WinGetTitle("A")
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
				WinActivate(title) ;reactivates the original window
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
	title := WinGetTitle("A")
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
SC03A & e::disc("DiscEdit.png") ;edit the message you're hovering over
SC03A & r::disc("DiscReply.png") ;reply to the message you're hovering over ;this reply hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
SC03A & a::disc("DiscReact.png") ;add a reaction to the message you're hovering over
SC03A & d::disc("DiscDelete.png") ;delete the message you're hovering over. Also hold shift to skip the prompt

;=============================================================================================================================================
;
;		Photoshop
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Photoshop.exe")
^+p::psType("png") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a png instead of the default psd
^+j::psType("jpg") ;When saving a file and highlighting the name of the document, this moves through and selects the output file as a jpg instead of the default psd

XButton1::mousedragNotPrem(handTool, penTool) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
Xbutton2::mousedragNotPrem(handTool, selectionTool) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
z::mousedragNotPrem(zoomTool, selectionTool) ;changes the tool to the zoom tool while z button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcut ini file to adjust hotkeys
;F1::psSave()

;=============================================================================================================================================
;
;		After Effects
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe AfterFX.exe")
Xbutton1::timeline("981", "550", "2542", "996") ;check MS_functions.ahk for the code to this preset & the keyboard ini file for keyboard shortcuts
Xbutton2::mousedragNotPrem(handAE, selectionAE) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard ini file for keyboard shortcuts
WheelRight::SendInput(nextKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys
WheelLeft::SendInput(previousKeyframe) ;check the keyboard shortcut ini file to adjust hotkeys

;=============================================================================================================================================
;
;		Premiere
;
;=============================================================================================================================================
#HotIf WinActive("ahk_exe Adobe Premiere Pro.exe")
;There use to be a lot of macros about here in the script, they have since been removed and moved to their own individual .ahk files as launching them directly
;via a streamdeck is far more effecient; 1. because I only ever launch them via the streamdeck anyway & 2. because that no longer requires me to eat up a hotkey
;that I could use elsewhere, to run them. These mentioned scripts can be found in the \Streamdeck AHK\ folder.

SC03A & z::SendInput(zoomOut) ;\\set zoom out in the keyboard shortcuts ini ;idk why tf I need the scancode for capslock here but I blame premiere
SC03A & v:: ;getting back to the selection tool while you're editing text will usually just input a v press instead so this script warps to the selection tool on your hotbar and presses it
{
	coords()
	MouseGetPos(&xpos, &ypos)
	SendInput(toolsWindow)
	SendInput(toolsWindow)
	sleep 50
	toolsClassNN := ControlGetClassNN(ControlGetFocus("A"))
	ControlGetPos(&toolx, &tooly, &width, &height, toolsClassNN)
	;MouseMove 34, 917 ;location of the selection tool
	if %&height% < 80 ;idk why but if the toolbar panel is less than 80 pixels tall the imagesearch fails for me????, but it only does that if using the &width/&height values of the controlgetpos. Ahk is weird sometimes
		multiply := "3"
	else
		multiply := "1"
	if ImageSearch(&x, &y, %&toolx%, %&tooly%, %&toolx% + %&width%, %&tooly% + %&height% * multiply, "*2 " Premiere "selection.png") ;moves to the selection tool
			MouseMove(%&x%, %&y%)
	else
		{
			toolFind("selection tool", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	click
	MouseMove %&xpos%, %&ypos%
}

RAlt & p:: ;This hotkey pulls out the project window and moves it to my second monitor since adobe refuses to just save its position in your workspace
{
	MouseGetPos(&xpos, &ypos)
	KeyWait("Alt")
	if GetKeyState("Ctrl", "P")
		{
			KeyWait("Ctrl")
			goto added
		}
	SendInput(resetWorkspace)
	sleep 1500
	ControlFocus "DroverLord - Window Class3" , "Adobe Premiere Pro" ;brings focus to premiere's timeline so the below activation of the project window DEFINITELY happens
	SendInput(projectsWindow) ;adjust this shortcut in the ini file
	coordw()
	ClassNN := ControlGetClassNN(ControlGetFocus("A"))
	ControlGetPos(&toolx, &tooly, &width, &height, ClassNN)
	blockOn()
	if ImageSearch(&prx, &pry, %&toolx% - "5", %&tooly% - "20", %&toolx% + "1000", %&tooly% + "100", "*2 " Premiere "project.png") ;searches for the project window to grab the track
		goto move
	else if ImageSearch(&prx, &pry, %&toolx% - "5", %&tooly% - "20", %&toolx% + "1000", %&tooly% + "100", "*2 " Premiere "project2.png") ;searches for the project window to grab the track
		goto move
	else if ImageSearch(&prx, &pry, %&toolx%, %&tooly%, %&width%, %&height%, "*2 " Premiere "project2.png")
		goto bin
	else ;if everything fails, this else will trigger
		{
			blockOff()
			toolFind("project window", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
			return
		}
	move:
	MouseMove(%&prx% + "5", %&pry% +"3")
	SendInput("{Click Down}")
	coords()
	Sleep 100
	MouseMove 3590, 702, "2"
	SendInput("{Click Up}")
	MouseMove(%&xpos%, %&ypos%)
	bin:
	Run("E:\Audio stuff")
	WinWait("E:\Audio stuff")
	WinActivate("E:\Audio stuff")
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
	if ImageSearch(&fold2x, &fold2y, 10, 3, 1038, 1072, "*2 " Premiere "sfxinproj.png")
		{
			MouseMove(%&fold2x% + "5", %&fold2y% + "2")
			SendInput("{Click 2}")
			sleep 100
		}
	else
		{
			blockOff()
			toolFind("the sfx folder in premiere", "2000")
			return
		}
	if ImageSearch(&fold3x, &fold3y, 10, 3, 1038, 1072, "*2 " Premiere "binsfx.png")
		{
			MouseMove(%&fold3x% + "5", %&fold3y% + "2")
			SendInput("{Click Down}")
			MouseMove(754, 1042, 2)
			sleep 150
			SendInput("{Click Up}")
		}
	else
		{
			blockOff()
			toolFind("the bin", "2000")
			return
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
WheelRight::wheelEditPoint(nextEditPoint) ;goes to the next edit point towards the right
WheelLeft::wheelEditPoint(previousEditPoint) ;goes to the next edit point towards the left
Xbutton1::SendInput(nudgeDown) ;Set ctrl w to "Nudge Clip Selection Down"
LAlt & Xbutton2:: ;this is necessary for the below function to work
Xbutton2::mousedrag(handPrem, selectionPrem) ;changes the tool to the hand tool while mouse button is held ;check MS_functions.ahk for the code to this preset & the keyboard shortcuts ini file for the tool shortcuts

F19::audioDrag("Goose_honk") ;drag my bleep (goose) sfx to the cursor ;I have a button on my mouse spit out F19 & F20
F20::audioDrag("bleep")

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		other - NOT an editor
;
;---------------------------------------------------------------------------------------------------------------------------------------------
GroupAdd("Editors", "ahk_exe Adobe Premiere Pro.exe")
GroupAdd("Editors", "ahk_exe AfterFX.exe")
#HotIf not WinActive("ahk_group Editors") ;code below here (until the next #HotIf) will trigger as long as premiere pro & after effects aren't active
^!w::monitorWarp("5044", "340") ;this simply warps my mouse to my far monitor bc I'm lazy YEP
^!+w::monitorWarp("1280", "720") ;this simply warps my mouse to my main monitor bc I'm lazy YEP
^+d::discLocation() ;Make discord bigger so I can actually read stuff when not streaming

F14::moveWin("") ;maximise
XButton2::moveWin("#{Left}") ;snap left
XButton1::moveWin("#{Right}") ;snap right
RButton::moveWin("") ;minimise

^SPACE::WinSetAlwaysOnTop -1, "A" ; will toggle the current window to remain on top

^+c:: ;runs a google search of highlighted text
{
	A_Clipboard := "" ;clears the clipboard
	Send "^c"
	ClipWait ;waits for the clipboard to contain data
	Run "https://www.google.com/search?d&q=" A_Clipboard
}

;---------------------------------------------------------------------------------------------------------------------------------------------
;
;		Mouse Scripts
;
;---------------------------------------------------------------------------------------------------------------------------------------------
;You can check out \mouse settings.png in the root repo to check what mouse buttons I have remapped
;The below scripts are to accelerate scrolling
F14 & WheelDown::SendInput("{WheelDown 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.
F14 & WheelUp::SendInput("{WheelUp 10}") ;I have one of my mouse buttons set to F14, so this is an easy way to accelerate scrolling. These scripts might do too much/little depending on what you have your windows mouse scroll settings set to.

;The below scripts are to swap between virtual desktops
F19 & XButton2::SendInput("^#{Right}") ;you don't need these two as a sendinput, the syntax highlighting I'm using just see's ^#Right as an error and it's annoying
F19 & XButton1::SendInput("^#{Left}")

;The below scripts are to skip ahead in the youtube player with the mouse
WheelRight::youMouse("l", "{Right}")
WheelLeft::youMouse("j", "{Left}")