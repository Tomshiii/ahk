;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
#SingleInstance Force
#Requires AutoHotkey v2.0-beta.1 ;this script requires AutoHotkey v2.0

;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.3.2

;\\CURRENT RELEASE VERSION
;\\v2.0

; =========================================================================
;		Coordmode \\ Last updated: v2.1.6
; =========================================================================
coords() ;sets coordmode to "screen"
{
	coordmode "pixel", "screen"
	coordmode "mouse", "screen"
}

coordw() ;sets coordmode to "window"
{
	coordmode "pixel", "window"
	coordmode "mouse", "window"
}

coordc() ;sets coordmode to "caret"
{
	coordmode "caret", "window"
}

; =========================================================================
;		Tooltip \\ Last updated: v2.3.2
; =========================================================================
toolT(message, timeout) ;create a tooltip
{
	ToolTip("couldn't find " %&message%)
	sleep %&timeout%
	ToolTip("")
}

; =========================================================================
;		Blockinput \\ Last updated: v2.0.1
; =========================================================================
blockOn() ;blocks all user inputs
{
	BlockInput "SendAndMouse"
	BlockInput "MouseMove"
	BlockInput "On"
}

blockOff() ;turns off the blocks on user input
{
	blockinput "MouseMoveOff"
	BlockInput "off"
}

; =========================================================================
;		discord \\ Last updated: v2.3.2
; =========================================================================
disc(imagepath) ;This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \ahk\ImageSearch\disc[button].png
;NOTE THESE WILL ONLY WORK IF YOU USE THE SAME DISPLAY SETTINGS AS ME. YOU WILL LIKELY NEED YOUR OWN SCREENSHOTS AS I HAVE DISCORD ON A VERTICAL SCREEN SO ALL MY SCALING IS WEIRD
;dark theme
;chat font scaling: 20px
;space between message groups: 16px
;zoom level: 100
;saturation; 70%

;&imagepath in this script is the path to the screenshot of the button you want the function to press
{
	coordw() ;important to leave this as window as otherwise the image search function might try searching your entire screen which isn't desirable
	MouseGetPos(&x, &y)
	blockOn()
	click "right"
	sleep 50 ;sleep required so the right click context menu has time to open
	If ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479, "*2 " A_WorkingDir %&imagepath%) ;*2 is required otherwise it spits out errors. check documentation for definition. These coords define the entire area discord contains text. Recommended to close the right sidebar or do this in a dm so you see the entire area discord normally shows messages
			MouseMove(%&xpos%, %&ypos%)
	else
		{
			sleep 500 ;this is a second attempt incase discord was too slow and didn't catch the button location the first time
			If ImageSearch(&xpos, &ypos, 312, 64, 1066, 1479, "*2 " A_WorkingDir %&imagepath%) ;this line is searching for the location of your selected button. Same goes for above. The coords here are the same as above
				MouseMove(%&xpos%, %&ypos%) ;Move to the location of the button
			else
				{
					MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
					blockOff()
					toolT("the requested button", "2000")
				}

		}
	Click
	sleep 100
	If ImageSearch(&xdir, &ydir, 330, 1380, 1066, 1461, "*2 " A_WorkingDir "\ImageSearch\Discord\DiscDirReply.bmp") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. If you prefer to leave that on, remove from the above sleep 100, to the else below. The coords here define just the bottom chat box AND the tiny bar that appears about it when you "reply" to someone
		{
			MouseMove(%&xdir%, %&ydir%) ;moves to the @ location
			Click
			MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
			blockOff()
		}
	else
		{
			MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
			blockOff()
			toolT("the @ ping button", "1000")
		}
}

; =========================================================================
;		Mouse Drag \\ Last updated: v2.3
; =========================================================================
mousedrag(tool, toolorig) ;press a button(ideally a mouse button), this script then changes to something similar to a "hand tool" and clicks so you can drag, then you set the hotkey for it to swap back to (selection tool for example)
;&tool is the thing you want the program to swap TO (ie, hand tool, zoom tool, etc)
;&toolorig is the button you want the script to press to bring you back to your tool of choice
{
	click "middle"
	SendInput %&tool% "{LButton Down}" 
	KeyWait A_ThisHotkey
	SendInput "{LButton Up}"
	SendInput %&toolorig% 
}

; =========================================================================
;		better timeline movement \\ Last updated: v2.1.11
; =========================================================================
timeline(timeline, x1, x2, y1) ;a weaker version of the right click premiere script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock)
;&timeline in this function defines the y pixel value of the top bar in your video editor that allows you to click it to drag along the timeline
;x1 is the furthest left pixel value of the timeline that will work with your cursor warping up to grab it
;x2 is the furthest right pixel value of the timeline that will work with your cursor warping up to grab it
;y1 is just below the bar that your mouse will be warping to, this way your mouse doesn't try doing things when you're doing other stuff above the timeline
{
	coordw()
	blockOn()
	MouseGetPos &xpos, &ypos
	if(%&xpos% > %&x1% and %&xpos% < %&x2%) and (%&ypos% > %&y1%) ;this function will only trigger if your cursor is within the timeline. This ofcourse can break if you accidently move around your workspace
		{
			MouseMove %&xpos%, %&timeline%
			SendInput "{Click Down}"
			MouseMove %&xpos%, %&ypos%
			blockOff()
			KeyWait A_ThisHotkey
			SendInput "{Click Up}"
		}
	else
		{
			blockOff()
			sleep 10
		}
}

; =========================================================================
;		Premiere \\ Last updated: v2.3.2
; =========================================================================
preset(item) ;this preset is for the drag and drop effect presets in premiere
;&item in this function defines what it will type into the search box (the name of your preset within premiere)
{
	blockOn()
	coords()
	MouseGetPos &xpos, &ypos
		SendInput "^+7"
		SendInput "^b" ;Requires you to set ctrl shift 7 to the effects window, then ctrl b to select find box
		SendInput "^a{DEL}"
		sleep 60
		coordc() ;change caret coord mode to window
		CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
		MouseMove %&carx%, %&cary% ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
		SendInput %&item% ;create a preset of any effect, must be in a folder as well
		MouseMove 40, 68,, "R" ;move down to the saved preset (must be in an additional folder)
		SendInput "{Click Down}"
		MouseMove %&xpos%, %&ypos% ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. If this happens to you, add ', "2" ' to the end of this mouse move
		SendInput "{Click Up}"
	blockOff()
}

num(xval, yval, scale) ;this function is to simply cut down repeated code on my numpad punch in scripts. it punches the video into my preset values for highlight videos
;&xval is the pixel value you want this function to paste into the X coord text field in premiere
;&yval is the pixel value you want this function to paste into the y coord text field in premiere
;&scale is the scale value you want this function to paste into the scale text field in premiere
{
	coordw()
	blockOn()
	MouseGetPos &xpos, &ypos
		SendInput "^+9"
		SendInput "^{F5}" ;highlights the timeline, then changes the track colour so I know that clip has been zoomed in
		If ImageSearch(&x, &y, 0, 960, 446, 1087, "*2 " A_WorkingDir "\ImageSearch\Premiere\video.png") ;moves to the "video" section of the effects control window tab
			MouseMove(%&x%, %&y%) ;I have no idea why this line matter but uh, if you don't have it here the script doesn't work so
		else
			goto end
		;SendInput "{WheelUp 30}" ;no longer required as the function wont finish if it can't find the image
		;MouseMove 122,1060 ;location for "motion"
		If ImageSearch(&x2, &y2, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\motion2.png") ;moves to the motion tab
			MouseMove(%&x2% + "10", %&y2% + "10")
		SendInput "{Click}"
		SendInput "{Tab 2}" %&xval% "{Tab}" %&yval% "{Tab}" %&scale% "{ENTER}"
		SendInput "{Enter}"
		end:
		MouseMove %&xpos%, %&ypos%
		blockOff()
}

fElse(data) ;a preset for the premiere scale, x/y and rotation scripts ;these wont work for resolve in their current form, you could adjust it to fit easily by copying over that code
;&data is what the script is typing in the text box (what your reset values are. ie 960 for a pixel coord, or 100 for scale)
{
	Click "{Click Up}"
	sleep 10
	Send %&data% 
	;MouseMove x, y ;if you want to press the reset arrow, input the windows spy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	sleep 50
	send "{enter}"
}

valuehold(filepath, data, optional) ;a preset to warp to one of a videos values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
;&filepath is the path to the image ImageSearch is going to use to find what value you want to adjust
;&data is what the script is typing in the text box (what your reset values are. ie 960 for a pixel coord, or 100 for scale)
;&optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
{
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
		;MouseMove 226, 1079 ;move to the "x" value
		If ImageSearch(&x, &y, 0, 911,705, 1354, "*2 " A_WorkingDir %&filepath%) ;finds the value you want to adjust, then finds the value adjustment to the right of it
			;MouseMove(%&x%, %&y%)
		{
			PixelSearch(&xcol, &ycol, %&x%, %&y%, %&x% + "740", %&y% + "40", 0x288ccf, 3) ;searches for the blue text to the right of the value you want to adjust
			If Color := 0x288ccf
			MouseMove(%&xcol% + %&optional%, %&ycol%)
		}
		else
			{
				toolT("the blue text", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
				goto move
			}
		sleep 100 ;required, otherwise it can't know if you're trying to tap to reset
			if GetKeyState(A_ThisHotkey, "P")
			{
				SendInput "{Click Down}"
				blockOff()
				KeyWait A_ThisHotkey
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else
			{
				If ImageSearch(&x2, &y2, %&x%, %&y% - "10", %&x% + "1500", %&y% + "20", "*2 " A_WorkingDir "\ImageSearch\Premiere\reset.png") ;searches for the reset button to the right of the value you want to adjust
					{
						MouseMove(%&x2%, %&y2%)
						SendInput("{Click}")
					}
				else
					{
						MouseMove %&xpos%, %&ypos%
						toolT("the reset button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
						goto move
					}
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
			move:
			blockOff()
}

; =========================================================================
;		Photoshop \\ Last updated: v2.3.2
; =========================================================================
psProp(image) ;a preset to warp to one of a photos values values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease.
;&image is the filepath to the image that imagesearch will use
{
	coords()
	MouseGetPos &xpos, &ypos
	coordw()
	blockOn()
	If ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " A_WorkingDir "\ImageSearch\Photoshop\text.png") ;checks to see if you're in the text tool
		SendInput("v") ;if you are, it'll press v to go to the selection tool
	If ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " A_WorkingDir "\ImageSearch\Photoshop\InTransform.png") ;checks to see if you're already in the free transform window
		{
			If ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " A_WorkingDir %&image%) ;if you are, it'll then search for your button of choice and move to it
			MouseMove(%&x%, %&y%)
		}
	else
		{
			SendInput("^t") ;if you aren't in the free transform it'll simply press ctrl t to get you into it
			sleep 200 ;photoshop is slow
			If ImageSearch(&x, &y, 111, 30, 744, 64, "*5 " A_WorkingDir %&image%) ;moves to the position variable
				MouseMove(%&x%, %&y%)
			else
				{
					MouseMove %&xpos%, %&ypos%
					blockOff()
					toolT("whatever you were looking for", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
				}
		}		
		sleep 100
		SendInput "{Click Down}"
			if GetKeyState(A_ThisHotkey, "P")
			{
				blockOff()
				KeyWait A_ThisHotkey
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else ;since we're in photoshop here, adding functionality for tapping the keys doesn't make much sense
			{
				Click "{Click Up}"
				;fElse(%&data%) ;check MS_functions.ahk for the code to this preset
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
}

; =========================================================================
;		Resolve \\ Last updated: v2.1.5
; =========================================================================
Rscale(item) ;to set the scale of a video within resolve
;&item is the number you want to type into the text field (100% in reslove requires a 1 here for example)
{
coordw()
blockOn()
MouseGetPos &xpos, &ypos
	click "2333, 218" ;clicks on video
	SendInput %&item%
	SendInput "{ENTER}"
	click "2292, 215" ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again.  Using the arrow would honestly be faster here
MouseMove %&xpos%, %&ypos%
blockOff()
}

rfElse(data) ;a preset for the resolve scale, x/y and rotation scripts
;&data is what the script is typing in the text box to reset its value
{
	SendInput "{Click Up}"
	sleep 10
	Send %&data%
	;MouseMove, x, y ;if you want to press the reset arrow, input the windowspy SCREEN coords here then comment out the above Send^
	;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
	;alternatively you could also run imagesearches like in the other resolve functions to ensure you always end up in the right place
	sleep 10
	send "{enter}"
	click "2295, 240" ;resolve is a bit weird if you press enter after text, it still lets you keep typing numbers, to prevent this, we just click somewhere else again.
}

Rfav(effect) ;apply any effect to the clip you're hovering over. this script requires the search box to be visible on the left side of the screen
;&effect is the name of the effect you want this function to type into the search box
{
coordw() ;
blockOn()
MouseGetPos &xpos, &ypos
If ImageSearch(&xi, &yi, 8, 752, 220, 803, "*2 " A_WorkingDir "\ImageSearch\Resolve\search.png") ;the search bar must be visible for this script to work. The coords in this function are to search for it
	{
		MouseMove(%&xi% + "10", %&yi% + "5")
		Click
		SendInput(%&effect%)
		MouseMove(189, 72,, "R")
		SendInput "{Click Down}"
		MouseMove %&xpos%, %&ypos%, 2
		SendInput "{Click Up}"
		MouseMove(%&xi% + "10", %&yi% + "5")
		click
	}
	else ;if for whatever reason the word "seach" isn't visible in the search box, this part of the function defaults back to just raw pixel coords
		{
			MouseMove(34, 775)
			Click
			SendInput(%&effect%)
			MouseMove(189, 72,, "R")
			SendInput "{Click Down}"
			MouseMove %&xpos%, %&ypos%, 2 ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
			SendInput "{Click Up}"
			MouseMove(34, 775)
			click
		}

	SendInput("^a" "{Del}")
	MouseMove %&xpos%, %&ypos%
	click "middle"
blockOff()
}

; =========================================================================
;		Fkey AutoLaunch \\ Last updated: v2.2
; =========================================================================
switchToExplorer()
{
;switchToExplorer(){
if not WinExist("ahk_class CabinetWClass")
	Run "explorer.exe"
GroupAdd "explorers", "ahk_class CabinetWClass"
if WinActive("ahk_exe explorer.exe")
	GroupActivate "explorers", "r"
else
	if WinExist("ahk_class CabinetWClass")
	WinActivate "ahk_class CabinetWClass" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToPremiere()
{
;switchToPremiere(){
if not WinExist("ahk_class Premiere Pro")
	{
	;Run, Adobe Premiere Pro.exe
	;Adobe Premiere Pro CC 2017
	; Run, C:\Program Files\Adobe\Adobe Premiere Pro CC 2017\Adobe Premiere Pro.exe ;if you have more than one version instlaled, you'll have to specify exactly which one you want to open.
	Run "Adobe Premiere Pro.exe"
	}
else
	if WinExist("ahk_class Premiere Pro")
	WinActivate "ahk_class Premiere Pro"
}

switchToFirefox()
{
;switchToFirefox(){
sendinput "{SC0E8}" ;scan code of an unassigned key. Do I NEED this?
if not WinExist("ahk_class MozillaWindowClass")
	Run "firefox.exe"
if WinActive("ahk_exe firefox.exe")
	{
	Class := WinGetClass("A")
	;WinGetClass class, A
	if (class = "Mozillawindowclass1")
		msgbox "this is a notification"
	}
if WinActive("ahk_exe firefox.exe")
	Send "^{tab}"
else
	{
		if WinExist("ahk_exe firefox.exe")
			;WinRestore ahk_exe firefox.exe
				WinActivate "ahk_exe firefox.exe"
	;sometimes winactivate is not enough. the window is brought to the foreground, but not put into FOCUS.
	;the below code should fix that.
	;Controls := WinGetControlsHwnd("ahk_class MozillaWindowClass")
	;WinGet hWnd ID ahk_class MozillaWindowClass
	;Result := DllCall("SetForegroundWindow UInt hWnd")
	;DllCall("SetForegroundWindow" UInt hWnd) 
	}
}

switchToOtherFirefoxWindow()
{
;switchToOtherFirefoxWindow(){
;sendinput, {SC0E8} ;scan code of an unassigned key

;Process Exist firefox.exe
;msgbox errorLevel `n%errorLevel%
	If (PID := ProcessExist("firefox.exe"))
	{
	GroupAdd "firefoxes", "ahk_class MozillaWindowClass"
	if WinActive("ahk_class MozillaWindowClass")
		GroupActivate "firefoxes", "r"
	else
		WinActivate "ahk_class MozillaWindowClass"
	}
	else
	Run "firefox.exe"
}

switchToVSC()
{
;switchToVSCodehub(){
if not WinExist("ahk_exe Code.exe")
	Run "C:\Users\Tom\AppData\Local\Programs\Microsoft VS Code\Code.exe"
GroupAdd "Code", "ahk_class Chrome_WidgetWin_1"
if WinActive("ahk_exe Code.exe")
	GroupActivate "Code", "r"
else
	if WinExist("ahk_exe Code.exe")
	WinActivate "ahk_exe Code.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToGithub()
{
;switchToGithub(){
if not WinExist("ahk_exe GitHubDesktop.exe")
	Run "C:\Users\Tom\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
GroupAdd "git", "ahk_class Chrome_WidgetWin_1"
if WinActive("ahk_exe GitHubDesktop.exe")
	GroupActivate "git", "r"
else
	if WinExist("ahk_exe GitHubDesktop.exe")
	WinActivate "ahk_exe GitHubDesktop.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToStreamdeck()
{
;switchToStreamdeck(){
if not WinExist("ahk_exe StreamDeck.exe")
	Run "C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"
GroupAdd "stream", "ahk_class Qt5152QWindowIcon"
if WinActive("ahk_exe StreamDeck.exe")
	GroupActivate "stream", "r"
else
	if WinExist("ahk_exe Streamdeck.exe")
	WinActivate "ahk_exe StreamDeck.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

switchToExcel()
{
	if not WinExist("ahk_exe EXCEL.EXE")
		Run A_ProgramFiles "\Microsoft Office\root\Office16\EXCEL.EXE"
	GroupAdd "xlmain", "ahk_class XLMAIN"
	if WinActive("ahk_exe EXCEL.EXE")
		GroupActivate "xlmain", "r"
	else
		if WinExist("ahk_exe EXCEL.EXE")
		WinActivate "ahk_exe EXCEL.EXE"
}

switchToWindowSpy()
{
	if not WinExist("WindowSpy.ahk")
		Run A_ProgramFiles "\AutoHotkey\WindowSpy.ahk"
	GroupAdd "winspy", "ahk_class AutoHotkeyGUI"
	if WinActive("WindowSpy.ahk")
		GroupActivate "winspy", "r"
	else
		if WinExist("WindowSpy.ahk")
		WinActivate "WindowSpy.ahk" ;you have to use WinActivatebottom if you didn't create a window group.
}


; =========================================================================
; Old
; =========================================================================
/* ;this was the old way of doing the discord functions (v2.0.7) that included just right clicking and making the user do things. I've saved the one with all variations of code it went through, the other two have been removed for cleanup as they were functionally identical
;PLEASE NOTE, I ORIGINALLY HAD THIS SCRIPT WARP THE MOUSE TO CERTAIN POSITIONS TO HIT THE RESPECTIVE BUTTONS BUT THE POSITION OF BUTTONS IN DISCORD WITHIN THE RIGHT CLICK CONTEXT MENU CHANGE DEPENDING ON WHAT PERMS YOU HAVE IN A SERVER, SO IT WOULD ALWAYS TRY TO DO RANDOM THINGS LIKE PIN A MESSAGE OR OPEN A THREAD. There isn't really anything you can do about that. I initially tried to just send through multiple down/up inputs but apparently discord rate limits you to like 1 input every .5-1s so that's fun.
discedit()
{
	{
		coords()
		MouseGetPos(&x, &y)
		blockOn()
		if(%&y% > 876) ;this value will need to be adjusted per your monitor. Because my monitor is rotated to sit vertically, "lower" on my screen is actually a higher y pixel value, hence the > instead of <
			{
				click "right"
				MouseMove(%&x%, 948) ;this value will need to be adjusted per your monitor - it's where the edit button sits when your mouse is towards the bottom of discord
				MouseMove(29, 0,, "R")
				;blockOff()
				;keywait "LButton", "D" ;tried to make it so the user presses the button you want since it moves everywhere depending on what perms you have in a server
				;click					;but it was too disorienting to make the user move, click, then warp the mouse back to the og position so
				;MouseMove(%&x%, %&y%)	;this is the best you can do here with the limitations of discord
			}
		else
			{
				click "right"
				MouseMove(29, 111,, "R") ;the y value here will need to be adjusted per your monitor
				;blockOff()				;I'll preserve this code in this first script, but remove it from the following two examples
				;keywait "LButton", "D"
				;click
				;MouseMove(%&x%, %&y%)
			}
		blockOff()
	}
}

this is the original way of doing value hold. Theoretically this isn't that bad, but if I move my effect controls too much, it would theoretically break
valuehold(x1, y1, x2, y2, button, data, optional) ;a preset to warp to one of a videos values (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
;&x1 is the pixel value for the first x coord for PixelSearch
;&y1 is the pixel value for the first y coord for PixelSearch
;&x2 is the pixel value for the second x coord for PixelSearch
;&y2 is the pixel value for the second y coord for PixelSearch
;&button is what button the function is being activated by (if you call this function from F1, put F1 here for example)
;&data is what the script is typing in the text box (what your reset values are. ie 960 for a pixel coord, or 100 for scale)
;&optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
{
	coords()
	blockOn()
	MouseGetPos &xpos, &ypos
		;MouseMove 226, 1079 ;move to the "x" value
		;If ImageSearch(&x, &y, 1, 965, 624, 1352, "*2 " A_WorkingDir "\ImageSearch\Premiere\position.png") ;moves to the position variable ;using an imagesearch here like this is only useful if I make the mouse move across until it "finds" the blue text. idk how to do that yet so this is getting commented out for now
			;MouseMove(%&x%, %&y%)
		If PixelSearch(&xcol, &ycol, %&x1%, %&y1%, %&x2%, %&y2%, 0x288ccf, 3) ;looks for the blue text to the right of scale
			MouseMove(%&xcol% + %&optional%, %&ycol%)
		sleep 100
		SendInput "{Click Down}"
			if GetKeyState(%&button%, "P")
			{
				blockOff()
				KeyWait %&button%
				SendInput "{Click Up}"
				MouseMove %&xpos%, %&ypos%
			}
			else
			{
				fElse(%&data%) ;check MS_functions.ahk for the code to this preset
				MouseMove %&xpos%, %&ypos%
				blockOff()
			}
}